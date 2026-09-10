#!/usr/bin/python3
#
# Root filesystem management script
#
# This scripts extends initramfs configuration syntax to
# include ipkg packages and enable file removal.
#
# Copyright (C) 2013-2016 Emcraft Systems
# Dmitry Konyshev <probables@emcraft.com>
#

import sys, os, re, subprocess, stat

_kconfig_cache = None

def kconfig_enabled(option):
    """Check if a kernel config option is set to y or m in the kernel .config"""
    global _kconfig_cache
    if _kconfig_cache is None:
        _kconfig_cache = set()
        kconfig_path = os.path.join(
            os.environ.get('INSTALL_ROOT', ''), 'linux', '.config')
        if os.path.isfile(kconfig_path):
            with open(kconfig_path, 'r') as f:
                for line in f:
                    m = re.match(r'^(CONFIG_\w+)=[ym]', line)
                    if m:
                        _kconfig_cache.add(m.group(1))
    return option in _kconfig_cache

def die(msg):
    print(sys.argv[0], ':', msg, file=sys.stderr)
    sys.exit(-1)

def cmd_ext(str):
    str = str.replace('\\', '/')
    #print >> sys.stderr, str
    pobj = subprocess.Popen(str, shell=True, stdout=subprocess.PIPE, \
                                stderr=subprocess.STDOUT, text=True)
    cc = pobj.wait()
    ret = []
    for s in pobj.stdout.readlines():
        ret.append(s.rstrip('\r\n'))
    #print >> sys.stderr, cc, ret
    return (cc, ret)

def cmd(str):
    (cc, ret) = cmd_ext(str)
    if cc:
        die('cmd "%s" failed' % str)
    return ret

def print_help():
    print('usage: rfs-builder.py <command>\n')
    print('Commands are:')
    print('\tpkg-list')
    print('\tpkg-add <initramfs cfg> <pkg name>')
    print('\tpkg-rm <initramfs cfg> <pkg name>')
    print('\tfile-add <initramfs cfg> <file name> <file path> <octal permissions>'
        ' <uid> <gid>')
    print('\tsymlink-add <initramfs cfg> <link name> <link path> <octal permissions>'
        ' <uid> <gid>')
    print('\tnod-add <initramfs cfg> <nod name> <octal permissions>'
        ' <uid> <gid> <c|b> <major> <minor>')
    print('\tdir-add <initramfs cfg> <dir name> <octal permissions>'
        ' <uid> <gid>')
    print('\tfile-rm <initramfs cfg> <file/slink/nod name>')
    print('\tdir-rm <initramfs cfg> <dir name>')
    print('\tlocaldir-add <initramfs cfg> <target dir name> <local dir name> <uid> <gid>')
    print('\tgenerate-rfs-image <initramfs cfg>')
    print('\tcreate-rfs-dir <initramfs cfg> <rfs-dir>')

def pkg_add(file_list, rep_path, pkg_name):
    with open(file_list, 'r') as f:
        pkgs = []
        for l in f.readlines():
            str = l.strip()
            m = re.search(r'^\s*opkg\s*(\S*)', str)
            if m:
                pkgs.append(m.group(1))

    if pkg_name in pkgs:
        die('package is already installed')

    cc, ret = cmd_ext('$(type -p opkg-cl) -o %s depends %s' % \
                          (rep_path, pkg_name))
    if cc:
        die('cannot get dependencies of ' + pkg_name)

    with open(file_list, 'a') as f:
        print('opkg %s' % pkg_name, file=f)
        print('Adding %s to %s' % (pkg_name, file_list))

        for l in ret:
            m = re.search(r'\s*(\S+)\s*\(>=', l)
            if not m:
                continue
            if m.group(1) not in pkgs:
                print('opkg %s' % m.group(1), file=f)
                print('Adding %s to %s as dependency of %s' %
                    (m.group(1), file_list, pkg_name))
            else:
                print('%s (dependency of %s) already exists, skipping' %
                    (m.group(1), pkg_name))

def pkg_rm(file_list, pkg_name):
    with open(file_list, 'r') as f:
        items = []
        for l in f.readlines():
            str = l.strip()
            m = re.search(r'^\s*opkg\s*(\S*)\s*(.*?)/?\s*$', str)
            if not m or m.group(1) != pkg_name:
                items.append(l)
            else:
                print('Removing %s from %s' % (pkg_name, file_list))
    with open(file_list, 'w') as f:
        for l in items:
            f.write(l)

def pkg_list(rep_path):
    ret = cmd('$(type -p opkg-cl) -o %s list' % rep_path)
    for item in ret:
        print(item)

def file_add(file_list, file_name, path, perm, uid, gid):
    with open(file_list, 'a') as f:
        print('file %s %s %04o %i %i' %
            (file_name, path, int(perm, 8), int(uid), int(gid)), file=f)
    print('Adding file %s to %s' % (file_name, file_list))

def slink_add(file_list, file_name, slink_path, perm, uid, gid):
    with open(file_list, 'a') as f:
        print('slink %s %s %04o %i %i' %
            (file_name, slink_path, int(perm, 8), int(uid), int(gid)), file=f)
    print('Adding symlink %s to %s' % (file_name, file_list))

def nod_add(file_list, file_name, perm, uid, gid, nod_type, major, minor):
    with open(file_list, 'a') as f:
        print('nod %s %04o %i %i %c %i %i' %
            (file_name, int(perm, 8), int(uid), int(gid), nod_type,
                 int(major), int(minor)), file=f)
    print('Adding nod %s to %s' % (file_name, file_list))

def dir_add(file_list, dir_name, perm, uid, gid):
    with open(file_list, 'a') as f:
        print('dir %s %04o %i %i' %
            (dir_name, int(perm, 8), int(uid), int(gid)), file=f)
    print('Adding directory %s to %s' % (dir_name, file_list))

def localdir_add(file_list, target_dir_name, local_dir_name):
    with open(file_list, 'a') as f:
        print('localdir %s %s' %
            (target_dir_name, local_dir_name), file=f)
    print('Adding local directory %s with its content to %s' %
        (local_dir_name, target_dir_name))

def file_rm(file_list, file_name, item_type):
    with open(file_list, 'a') as f:
        if item_type == 'dir':
            print('rmdir %s' % file_name, file=f)
        else:
            print('rm %s' % file_name, file=f)
    print('Adding removal of %s to %s' % (file_name, file_list))

def preprocess_directives(lines):
    # process the `ifdef`, `ifndef` and `include` directives
    i = 0
    while i < len(lines):
        l = lines[i]
        m = re.search(r'^\s*ifdef\s*(\S+)\s*(.*?)$', l)
        if m:
            if m.group(1) not in os.environ:
                del lines[i]
                continue
            else:
                lines[i] = m.group(2)
                i += 1
                continue
        m = re.search(r'^\s*ifndef\s*(\S+)\s*(.*?)$', l)
        if m:
            if m.group(1) in os.environ:
                del lines[i]
                continue
            else:
                lines[i] = m.group(2)
                i += 1
                continue
        m = re.search(r'^\s*include\s*(".*?"|\S*)/?\s*', l)
        if m:
            inc = re.sub(r'\$\{(.*?)\}', lambda r: os.environ.get(r.group(1), ''), m.group(1))
            with open(inc, 'r') as f:
                inc_lines = f.readlines()
            lines[i:i+1] = inc_lines
            continue
        i += 1


def generate_rfs_image(file_list):
    with open(file_list, 'r') as f:
        lines = f.readlines()

    preprocess_directives(lines)

    rfs_items = []
    names2lines = {}
    pkgs = {}
    dirs = []
    splitfs = []

    skip_dir = "skip-this-dir"

    # check that all dirs in the path exist
    def check_path(fn):
        if fn == '' or fn == '/' or fn in dirs:
            return

        if len(fn) >= len(skip_dir) and fn[:len(skip_dir)] == skip_dir:
            return

        prnt, cur = os.path.split(fn)
        check_path(prnt)
        if fn not in dirs:
            rfs_items.append("dir %s 755 0 0" % fn)
            names2lines[fn] = len(rfs_items) - 1
            dirs.append(fn)

    # the most recent reference to file (node, slink) substitues the previous one
    def add_file(fn, linenum, line_txt):
        if fn in names2lines:
            rfs_items[names2lines[fn]] = ("# dup of %i: " % (linenum + 1)) + \
                rfs_items[names2lines[fn]]
        check_path(os.path.split(fn)[0])
        rfs_items.append(line_txt)
        names2lines[fn] = len(rfs_items) - 1

    # the first copy of a directory is used, others ignored
    def add_dir(fn, line_txt):
        check_path(os.path.split(fn)[0])
        if fn in names2lines:
            rfs_items.append('# dup of %i: %s' % (names2lines[fn] + 1, line_txt))
        else:
            rfs_items.append(line_txt)
            names2lines[fn] = len(rfs_items) - 1
        dirs.append(fn)

    # return true if there are 3-th and 4-th arguments
    def need_to_subst(args):
        return len(args) >= 4

    def shall_be_subst(args, p):
        if need_to_subst(args):
            old = args[2].rstrip('/') + '/'
            new = args[3].rstrip('/') + '/'
            if len(p) > len(old) and p[:len(old)] == old:
                return True
        return False

    def add_dir_link(args, p):
        #
        # Make a link for nested directories:
        #   p = /usr/lib/fonts/smth
        #   p = /usr/lib/ts
        #   p = /usr/lib/ts/smth
        #   ...
        #
        # In these cases we need to create symlinks in root and splitfs:
        #   /usr/lib/fonts -> /lib/fonts
        #   /usr/lib/ts    -> /lib/ts
        #   ...

        old = args[2].rstrip('/') + '/'
        new = args[3].rstrip('/') + '/'

        # cut old directory, e.g., p = fonts/smth
        p = p[len(old):]

        # if p contained '/', then create a symlink
        p = p.split('/')
        if len(p) > 1:
            p = p[0] # p = fonts
            txt = "slink %s %s 0777 0 0" % (old + p, new + p)
            add_file(old + p, i, txt)       # this one goes to splitfs
            add_file(skip_dir + p, i, txt)  # this one goes to rootfs
            return True
        return False

    def add_slink_if_needed(args, p):
        if shall_be_subst(args, p):
            txt = "slink %s %s 0777 0 0" % (p, subst_path(args, p))
            if not add_dir_link(args, p):       # this one to add a link to nested directories
                add_file(p, i, txt)             # this one goes to splitfs
                add_file(skip_dir + p, i, txt)  # this one goes to rootfs

    def subst_path(args, p):
        if need_to_subst(args):
            old = args[2].rstrip('/') + '/'
            new = args[3].rstrip('/') + '/'
            if len(p) > len(old) and p[:len(old)] == old:
                return new + p[len(old):]
        return p

    def add_files_from_local_dir(tpath, lpath, linenum, orig_lpath, uid, gid):
        st = os.stat(lpath)
        txt = 'dir %s %3o %s %s' % (tpath, \
                                        stat.S_IMODE(st.st_mode),	\
                                        uid, gid)
        add_dir(tpath, txt)
        lpath = lpath + '/'
        tpath = tpath + '/'
        for f in os.listdir(lpath):
            if os.path.isdir(lpath + f):
                add_files_from_local_dir(tpath + f, lpath + f, linenum, orig_lpath, uid, gid)
            elif os.path.islink(lpath + f):
                st = os.lstat(lpath + f)
                realfn = os.readlink(lpath + f)
                if realfn.find(lpath) == 0:
                    realfn = realfn[len(lpath):]
                if realfn.find(orig_lpath) == 0:
                    realfn = realfn[len(orig_lpath):]
                txt = 'slink %s %s %3o %s %s' % \
                    (tpath + f, \
                         realfn, \
                         stat.S_IMODE(st.st_mode),	\
                         uid, gid)
                add_file(tpath + f, linenum, txt)
            elif os.path.isfile(lpath + f):
                st = os.stat(lpath + f)
                txt = 'file %s %s %3o %s %s' % \
                    (tpath + f, \
                         lpath + f, stat.S_IMODE(st.st_mode),	\
                         uid, gid)
                add_file(tpath + f, linenum, txt)
            else:
                die('Unknown file type')

    i = -1
    for l in lines:
        str = l.strip()
        i = i + 1
        # Concatenate strings separated with '\'
        if str.endswith("\\"):
          str = str.rstrip('\\')
          str = str + lines[i + 1]
          lines[i + 1] = str
          continue

        m = re.search(r'^\s*ifkconfig\s*(\S*)\s*(.*?)$', str)
        if m:
            if not kconfig_enabled(m.group(1)):
                rfs_items.append('# disable no kconfig: ' + str)
                continue
            else:
                str = m.group(2)
        m = re.search(r'^\s*ifnkconfig\s*(\S*)\s*(.*?)$', str)
        if m:
            if kconfig_enabled(m.group(1)):
                rfs_items.append('# disable kconfig: ' + str)
                continue
            else:
                str = m.group(2)
        m = re.search(r'^\s*ifarch\s*(\S*)\s*(.*?)$', str)
        if m:
            if 'MCU' not in os.environ or os.environ['MCU'] != m.group(1):
                rfs_items.append('# disable no arch: ' + str)
                continue
            else:
                str = m.group(2)
        m = re.search(r'^\s*ifnarch\s*(\S*)\s*(.*?)$', str)
        if m:
            if 'MCU' in os.environ and os.environ['MCU'] == m.group(1):
                rfs_items.append('# disable arch: ' + str)
                continue
            else:
                str = m.group(2)
        str = re.sub(r'\$\{(.*?)\}', lambda r: os.environ.get(r.group(1), ''), str)
        m = re.search(r'^\s*(file|nod|dir|slink)\s*(".*?"|\S*)/?\s*', str)
        if m:
            if m.group(1) == 'dir':
                add_dir(m.group(2), str)
            else:
                add_file(m.group(2), i, str)
            continue

        m = re.search(r'^\s*opkg\s*(\S*)', str)
        if m:
            opkg_args = str.split()
            if opkg_args[1] in pkgs:
                rfs_items.append('# dup of %i: %s' %
                                 (pkgs[opkg_args[1]] + 1, str))
                continue

            pkgs[opkg_args[1]] = i

            rep_path = os.environ.get('ELDK_ROOTFS', '')
            cc, ret = cmd_ext('$(type -p opkg-cl) -o %s files %s' % \
                                  (rep_path, opkg_args[1]))
            if cc != 0:
                die('cannot get the list of files for package %s' % opkg_args[1])

            rfs_items.append('# opkg package %s' % opkg_args[1])
            for pkt in ret[1:]:
                p = re.search(r'^%s(.*?)/?$' % rep_path, pkt)
                if not p:
                    die('cannot get the list of files for package %s' % opkg_args[1])
                if os.path.isdir(pkt):
                    st = os.stat(pkt)
                    txt = 'dir %s %3o %i %i' % (subst_path(opkg_args, p.group(1)), \
                                           stat.S_IMODE(st.st_mode),	\
                                           st.st_uid, st.st_gid)
                    add_dir(subst_path(opkg_args, pkt[len(rep_path):-1]), txt)
                    add_slink_if_needed(opkg_args, p.group(1))
                elif os.path.islink(pkt):
                    st = os.lstat(pkt)
                    realfn = os.readlink(pkt)
                    if realfn.find(rep_path) == 0:
                        realfn = realfn[len(rep_path):]
                    txt = 'slink %s %s %3o %i %i' % \
                        (subst_path(opkg_args, p.group(1)), \
                             realfn, \
                             stat.S_IMODE(st.st_mode),	\
                             st.st_uid, st.st_gid)
                    add_file(subst_path(opkg_args, pkt[len(rep_path):]), i, txt)
                    add_slink_if_needed(opkg_args, p.group(1))
                elif os.path.isfile(pkt):
                    st = os.stat(pkt)
                    txt = 'file %s %s %3o %i %i' % \
                        (subst_path(opkg_args, p.group(1)), \
                             pkt, stat.S_IMODE(st.st_mode),	\
                             st.st_uid, st.st_gid)
                    add_file(subst_path(opkg_args, pkt[len(rep_path):]), i, txt)
                    add_slink_if_needed(opkg_args, p.group(1))
                else:
                    die('Unknown file type')
            continue

        m = re.search(r'^\s*(rm|rmdir)\s*(\S*)/?\s*$', str)
        if m:
            if m.group(1) == 'rm':
                if m.group(2) in names2lines:
                    rfs_items[names2lines[m.group(2)]] = \
                        ("# rm from %i: " % (i + 1)) + \
                        rfs_items[names2lines[m.group(2)]]
                    del names2lines[m.group(2)]
            else:
                for nm in list(names2lines.keys()):
                    if nm == m.group(2) or nm.find(m.group(2) + '/') == 0:
                        rfs_items[names2lines[nm]] = \
                            ("# rm from %i: " % (i + 1)) + \
                            rfs_items[names2lines[nm]]
                        del names2lines[nm]
            continue

        m = re.search(r'^\s*localdir\s*(\S+)/?\s*(\S+)/?\s*(\S+)/?\s*(\S+)/?\s*$', str)
        if m:
            add_files_from_local_dir(m.group(1), m.group(2), i, m.group(2), m.group(3), m.group(4))
            continue

        m = re.search(r'^\s*splitfs\s*(\S+)/?\s*(\S+)/?\s*$', str)
        if m:
            splitfs.append((m.group(1), m.group(2)))
            continue

        rfs_items.append(str)

    all_paths = sorted(names2lines.items(), key=lambda item: item[1])
    for (p, ifn) in splitfs:
        with open(ifn, "w") as f:
            for nm in all_paths:
                if nm[0] != p and nm[0].find(p + '/') == 0:
                    f.write(rfs_items[nm[1]].replace(p, '', 1) + '\n')
                    rfs_items[nm[1]] = \
                        ("# splitfs to %s: " % (ifn)) + \
                        rfs_items[nm[1]]
                    del names2lines[nm[0]]

    for l in rfs_items:
        print(l)

def create_rfs_dir(file_list, rfs):
    if rfs[-1] != '/':
        rfs = rfs + '/'

    with open(file_list, 'r') as f:
        lines = f.readlines()

    preprocess_directives(lines)

    cmd('rm -rf %s' % rfs)

    i = -1
    for l in lines:
        str = l.strip()
        i = i + 1
        # Concatenate strings separated with '\'
        if str.endswith("\\"):
          str = str.rstrip('\\')
          str = str + lines[i + 1]
          lines[i + 1] = str
          continue

        m = re.search(r'^\s*ifkconfig\s*(\S*)\s*(.*?)$', str)
        if m:
            if not kconfig_enabled(m.group(1)):
                continue
            else:
                str = m.group(2)
        m = re.search(r'^\s*ifnkconfig\s*(\S*)\s*(.*?)$', str)
        if m:
            if kconfig_enabled(m.group(1)):
                continue
            else:
                str = m.group(2)
        m = re.search(r'^\s*ifarch\s*(\S*)\s*(.*?)$', str)
        if m:
            if 'MCU' not in os.environ or os.environ['MCU'] != m.group(1):
                continue
            else:
                str = m.group(2)
        str = re.sub(r'\$\{(.*?)\}', lambda r: os.environ.get(r.group(1), ''), str)

        m = re.search(r'^\s*file\s*', str)
        if m:
            m = re.search(r'^\s*file\s*(\S*)\s*(\S*)\s*(\d*)\s*(\d*)\s*(\d*)', str)
            if m:
                cmd('mkdir -p %s' % os.path.dirname(rfs + m.group(1)))
                cmd('cp %s %s' % (m.group(2), rfs + m.group(1)))
                cmd('chmod %s %s' % (m.group(3), rfs + m.group(1)))
            else:
                die('wrong syntax at "%s"' % m.group(0))
            continue

        m = re.search(r'^\s*dir\s*', str)
        if m:
            m = re.search(r'^\s*dir\s*(\S*)\s*(\d*)\s*(\d*)\s*(\d*)', str)
            if m:
                cmd('mkdir -p %s' % (rfs + m.group(1)))
                cmd('chmod %s %s' % (m.group(2), rfs + m.group(1)))
            else:
                die('wrong syntax at "%s"' % m.group(0))
            continue

        m = re.search(r'^\s*slink\s*', str)
        if m:
            m = re.search(r'^\s*slink\s*(\S*)\s*(\S*)\s*(\d*)\s*(\d*)\s*(\d*)', str)
            if m:
                cmd('mkdir -p %s' % os.path.dirname(rfs + m.group(1)))
                cmd('ln -sf %s %s' % (m.group(2), rfs + m.group(1)))
                #cmd('chmod %s %s' % (m.group(3), rfs + m.group(1)))
            else:
                die('wrong syntax at "%s"' % m.group(0))
            continue

        m = re.search(r'^\s*opkg\s*', str)
        if m:
            m = re.search(r'^\s*opkg\s*(\S*)', str)
            if m:
                cmd('opkg-cl --no-install-recommends -o %s install %s' % (rfs, m.group(1)))
            else:
                die('wrong syntax at "%s"' % m.group(0))
            continue

        m = re.search(r'^\s*localdir\s*', str)
        if m:
            m = re.search(r'^\s*localdir\s*(\S*)\s*(\S*)', str)
            if m:
                # Copy the source directory's contents into the destination so
                # the result is the same whether or not a preceding `dir`
                # directive already created it (a plain `cp -a src dest` would
                # nest src under an existing dest).
                cmd('mkdir -p %s' % (rfs + m.group(1)))
                cmd('cp -a %s/. %s' % (m.group(2), rfs + m.group(1)))
            else:
                die('wrong syntax at "%s"' % m.group(0))
            continue

if __name__ == '__main__':
    if len(sys.argv) == 1:
        print_help()
        exit(-1)

    if sys.argv[1] == 'pkg-add':
        if len(sys.argv) < 4:
            print('too few arguments supplied to pkg-add command')
            print_help()
            exit(-1)
        pkg_add(sys.argv[2], os.environ.get('ELDK_ROOTFS', ''), sys.argv[3])
    elif sys.argv[1] == 'pkg-rm':
        if len(sys.argv) < 4:
            print('too few arguments supplied to pkg-rm command')
            print_help()
            exit(-1)
        pkg_rm(sys.argv[2], sys.argv[3])
    elif sys.argv[1] == 'pkg-list':
        pkg_list(os.environ.get('ELDK_ROOTFS', ''))
    elif sys.argv[1] == 'file-add':
        if len(sys.argv) < 8:
            print('too few arguments supplied to file-add command')
            print_help()
            exit(-1)
        file_add(sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5],
                sys.argv[6], sys.argv[7])
    elif sys.argv[1] == 'symlink-add':
        if len(sys.argv) < 8:
            print('too few arguments supplied to symlink-add command')
            print_help()
            exit(-1)
        slink_add(sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5],
                sys.argv[6], sys.argv[7])
    elif sys.argv[1] == 'nod-add':
        if len(sys.argv) < 10:
            print('too few arguments supplied to nod-add command')
            print_help()
            exit(-1)
        nod_add(sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5],
                sys.argv[6], sys.argv[7], sys.argv[8], sys.argv[9])
    elif sys.argv[1] == 'dir-add':
        if len(sys.argv) < 7:
            print('too few arguments supplied to dir-add command')
            print_help()
            exit(-1)
        dir_add(sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5],
                sys.argv[6])
    elif sys.argv[1] == 'localdir-add':
        if len(sys.argv) < 5:
            print('too few arguments supplied to localdir-add command')
            print_help()
            exit(-1)
        localdir_add(sys.argv[2], sys.argv[3], sys.argv[4])
    elif sys.argv[1] == 'file-rm':
        if len(sys.argv) < 4:
            print('too few arguments supplied to file-rm command')
            print_help()
            exit(-1)
        file_rm(sys.argv[2], sys.argv[3], 'file')
    elif sys.argv[1] == 'dir-rm':
        if len(sys.argv) < 4:
            print('too few arguments supplied to dir-rm command')
            print_help()
            exit(-1)
        file_rm(sys.argv[2], sys.argv[3], 'dir')
    elif sys.argv[1] == 'generate-rfs-image':
        if len(sys.argv) < 3:
            print('too few arguments supplied to generate-rfs-image command')
            print_help()
            exit(-1)
        generate_rfs_image(sys.argv[2])
    elif sys.argv[1] == 'create-rfs-dir':
        if len(sys.argv) < 4:
            print('too few arguments supplied to create-rfs-dir command')
            print_help()
            exit(-1)
        create_rfs_dir(sys.argv[2], sys.argv[3])
    else:
        print_help()
        exit(-1)

    sys.exit(0)
