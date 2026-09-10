/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

/*
 * Evdev example...
 * Pulled from http://www.frogmouth.net/hid-doco/c537.html
 */

#include <stdlib.h>
#include <stdio.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <asm/types.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdint.h>
#include <string.h>

#include <linux/input.h>

static const char *int2str(int i)
{
	char buf[16];

	snprintf(buf, sizeof buf, "%i", i);
	return strdup(buf);
}

static const char *evtype(struct input_event *e)
{
#define STR(N) N: return #N
	switch (e->type) {
	case STR(EV_SYN);
	case STR(EV_KEY);
	case STR(EV_REL);
	case STR(EV_ABS);
	case STR(EV_MSC);
	case STR(EV_SW);
	case STR(EV_LED);
	case STR(EV_SND);
	case STR(EV_REP);
	case STR(EV_FF);
	case STR(EV_PWR);
	case STR(EV_FF_STATUS);
	default:
		return int2str(e->type);
	}
#undef STR
}

static const char *syn_code(int code)
{
#define STR(N) N: return #N
	switch (code) {
	case STR(SYN_REPORT);
	case STR(SYN_CONFIG);
	case STR(SYN_MT_REPORT);
	default: return int2str(code);
	}
#undef STR
}

static const char *key_code(int code)
{
#define STR(N) N: return #N
	switch (code) {
	case STR(KEY_RESERVED);
	case STR(KEY_ESC);
	case STR(KEY_1);
	case STR(KEY_2);
	case STR(KEY_3);
	case STR(KEY_4);
	case STR(KEY_5);
	case STR(KEY_6);
	case STR(KEY_7);
	case STR(KEY_8);
	case STR(KEY_9);
	case STR(KEY_0);
	case STR(KEY_MINUS);
	case STR(KEY_EQUAL);
	case STR(KEY_BACKSPACE);
	case STR(KEY_TAB);
	case STR(KEY_Q);
	case STR(KEY_W);
	case STR(KEY_E);
	case STR(KEY_R);
	case STR(KEY_T);
	case STR(KEY_Y);
	case STR(KEY_U);
	case STR(KEY_I);
	case STR(KEY_O);
	case STR(KEY_P);
	case STR(KEY_LEFTBRACE);
	case STR(KEY_RIGHTBRACE);
	case STR(KEY_ENTER);
	case STR(KEY_LEFTCTRL);
	case STR(KEY_A);
	case STR(KEY_S);
	case STR(KEY_D);
	case STR(KEY_F);
	case STR(KEY_G);
	case STR(KEY_H);
	case STR(KEY_J);
	case STR(KEY_K);
	case STR(KEY_L);
	case STR(KEY_SEMICOLON);
	case STR(KEY_APOSTROPHE);
	case STR(KEY_GRAVE);
	case STR(KEY_LEFTSHIFT);
	case STR(KEY_BACKSLASH);
	case STR(KEY_Z);
	case STR(KEY_X);
	case STR(KEY_C);
	case STR(KEY_V);
	case STR(KEY_B);
	case STR(KEY_N);
	case STR(KEY_M);
	case STR(KEY_COMMA);
	case STR(KEY_DOT);
	case STR(KEY_SLASH);
	case STR(KEY_RIGHTSHIFT);
	case STR(KEY_KPASTERISK);
	case STR(KEY_LEFTALT);
	case STR(KEY_SPACE);
	case STR(KEY_CAPSLOCK);
	case STR(KEY_F1);
	case STR(KEY_F2);
	case STR(KEY_F3);
	case STR(KEY_F4);
	case STR(KEY_F5);
	case STR(KEY_F6);
	case STR(KEY_F7);
	case STR(KEY_F8);
	case STR(KEY_F9);
	case STR(KEY_F10);
	case STR(KEY_NUMLOCK);
	case STR(KEY_SCROLLLOCK);
	case STR(KEY_KP7);
	case STR(KEY_KP8);
	case STR(KEY_KP9);
	case STR(KEY_KPMINUS);
	case STR(KEY_KP4);
	case STR(KEY_KP5);
	case STR(KEY_KP6);
	case STR(KEY_KPPLUS);
	case STR(KEY_KP1);
	case STR(KEY_KP2);
	case STR(KEY_KP3);
	case STR(KEY_KP0);
	case STR(KEY_KPDOT);
	case STR(KEY_ZENKAKUHANKAKU);
	case STR(KEY_102ND);
	case STR(KEY_F11);
	case STR(KEY_F12);
	case STR(KEY_RO);
	case STR(KEY_KATAKANA);
	case STR(KEY_HIRAGANA);
	case STR(KEY_HENKAN);
	case STR(KEY_KATAKANAHIRAGANA);
	case STR(KEY_MUHENKAN);
	case STR(KEY_KPJPCOMMA);
	case STR(KEY_KPENTER);
	case STR(KEY_RIGHTCTRL);
	case STR(KEY_KPSLASH);
	case STR(KEY_SYSRQ);
	case STR(KEY_RIGHTALT);
	case STR(KEY_LINEFEED);
	case STR(KEY_HOME);
	case STR(KEY_UP);
	case STR(KEY_PAGEUP);
	case STR(KEY_LEFT);
	case STR(KEY_RIGHT);
	case STR(KEY_END);
	case STR(KEY_DOWN);
	case STR(KEY_PAGEDOWN);
	case STR(KEY_INSERT);
	case STR(KEY_DELETE);
	case STR(KEY_MACRO);
	case STR(KEY_MUTE);
	case STR(KEY_VOLUMEDOWN);
	case STR(KEY_VOLUMEUP);
	case STR(KEY_POWER);
	case STR(KEY_KPEQUAL);
	case STR(KEY_KPPLUSMINUS);
	case STR(KEY_PAUSE);
	case STR(KEY_SCALE);
	case STR(KEY_KPCOMMA);
	case STR(KEY_HANGEUL);
	case STR(KEY_HANJA);
	case STR(KEY_YEN);
	case STR(KEY_LEFTMETA);
	case STR(KEY_RIGHTMETA);
	case STR(KEY_COMPOSE);
	case STR(KEY_STOP);
	case STR(KEY_AGAIN);
	case STR(KEY_PROPS);
	case STR(KEY_UNDO);
	case STR(KEY_FRONT);
	case STR(KEY_COPY);
	case STR(KEY_OPEN);
	case STR(KEY_PASTE);
	case STR(KEY_FIND);
	case STR(KEY_CUT);
	case STR(KEY_HELP);
	case STR(KEY_MENU);
	case STR(KEY_CALC);
	case STR(KEY_SETUP);
	case STR(KEY_SLEEP);
	case STR(KEY_WAKEUP);
	case STR(KEY_FILE);
	case STR(KEY_SENDFILE);
	case STR(KEY_DELETEFILE);
	case STR(KEY_XFER);
	case STR(KEY_PROG1);
	case STR(KEY_PROG2);
	case STR(KEY_WWW);
	case STR(KEY_MSDOS);
	case STR(KEY_COFFEE);
	case STR(KEY_DIRECTION);
	case STR(KEY_CYCLEWINDOWS);
	case STR(KEY_MAIL);
	case STR(KEY_BOOKMARKS);
	case STR(KEY_COMPUTER);
	case STR(KEY_BACK);
	case STR(KEY_FORWARD);
	case STR(KEY_CLOSECD);
	case STR(KEY_EJECTCD);
	case STR(KEY_EJECTCLOSECD);
	case STR(KEY_NEXTSONG);
	case STR(KEY_PLAYPAUSE);
	case STR(KEY_PREVIOUSSONG);
	case STR(KEY_STOPCD);
	case STR(KEY_RECORD);
	case STR(KEY_REWIND);
	case STR(KEY_PHONE);
	case STR(KEY_ISO);
	case STR(KEY_CONFIG);
	case STR(KEY_HOMEPAGE);
	case STR(KEY_REFRESH);
	case STR(KEY_EXIT);
	case STR(KEY_MOVE);
	case STR(KEY_EDIT);
	case STR(KEY_SCROLLUP);
	case STR(KEY_SCROLLDOWN);
	case STR(KEY_KPLEFTPAREN);
	case STR(KEY_KPRIGHTPAREN);
	case STR(KEY_NEW);
	case STR(KEY_REDO);
	case STR(KEY_F13);
	case STR(KEY_F14);
	case STR(KEY_F15);
	case STR(KEY_F16);
	case STR(KEY_F17);
	case STR(KEY_F18);
	case STR(KEY_F19);
	case STR(KEY_F20);
	case STR(KEY_F21);
	case STR(KEY_F22);
	case STR(KEY_F23);
	case STR(KEY_F24);
	case STR(KEY_PLAYCD);
	case STR(KEY_PAUSECD);
	case STR(KEY_PROG3);
	case STR(KEY_PROG4);
	case STR(KEY_DASHBOARD);
	case STR(KEY_SUSPEND);
	case STR(KEY_CLOSE);
	case STR(KEY_PLAY);
	case STR(KEY_FASTFORWARD);
	case STR(KEY_BASSBOOST);
	case STR(KEY_PRINT);
	case STR(KEY_HP);
	case STR(KEY_CAMERA);
	case STR(KEY_SOUND);
	case STR(KEY_QUESTION);
	case STR(KEY_EMAIL);
	case STR(KEY_CHAT);
	case STR(KEY_SEARCH);
	case STR(KEY_CONNECT);
	case STR(KEY_FINANCE);
	case STR(KEY_SPORT);
	case STR(KEY_SHOP);
	case STR(KEY_ALTERASE);
	case STR(KEY_CANCEL);
	case STR(KEY_BRIGHTNESSDOWN);
	case STR(KEY_BRIGHTNESSUP);
	case STR(KEY_MEDIA);
	case STR(KEY_SWITCHVIDEOMODE);
	case STR(KEY_KBDILLUMTOGGLE);
	case STR(KEY_KBDILLUMDOWN);
	case STR(KEY_KBDILLUMUP);
	case STR(KEY_SEND);
	case STR(KEY_REPLY);
	case STR(KEY_FORWARDMAIL);
	case STR(KEY_SAVE);
	case STR(KEY_DOCUMENTS);
	case STR(KEY_BATTERY);
	case STR(KEY_BLUETOOTH);
	case STR(KEY_WLAN);
	case STR(KEY_UWB);
	case STR(KEY_UNKNOWN);
	case STR(KEY_VIDEO_NEXT);
	case STR(KEY_VIDEO_PREV);
	case STR(KEY_BRIGHTNESS_CYCLE);
	case STR(KEY_BRIGHTNESS_ZERO);
	case STR(KEY_DISPLAY_OFF);
	case STR(KEY_WIMAX);
	case STR(KEY_RFKILL);
	case STR(BTN_0);
	case STR(BTN_1);
	case STR(BTN_2);
	case STR(BTN_3);
	case STR(BTN_4);
	case STR(BTN_5);
	case STR(BTN_6);
	case STR(BTN_7);
	case STR(BTN_8);
	case STR(BTN_9);
	case STR(BTN_LEFT);
	case STR(BTN_RIGHT);
	case STR(BTN_MIDDLE);
	case STR(BTN_SIDE);
	case STR(BTN_EXTRA);
	case STR(BTN_FORWARD);
	case STR(BTN_BACK);
	case STR(BTN_TASK);
	case STR(BTN_TRIGGER);
	case STR(BTN_THUMB);
	case STR(BTN_THUMB2);
	case STR(BTN_TOP);
	case STR(BTN_TOP2);
	case STR(BTN_PINKIE);
	case STR(BTN_BASE);
	case STR(BTN_BASE2);
	case STR(BTN_BASE3);
	case STR(BTN_BASE4);
	case STR(BTN_BASE5);
	case STR(BTN_BASE6);
	case STR(BTN_DEAD);
	case STR(BTN_A);
	case STR(BTN_B);
	case STR(BTN_C);
	case STR(BTN_X);
	case STR(BTN_Y);
	case STR(BTN_Z);
	case STR(BTN_TL);
	case STR(BTN_TR);
	case STR(BTN_TL2);
	case STR(BTN_TR2);
	case STR(BTN_SELECT);
	case STR(BTN_START);
	case STR(BTN_MODE);
	case STR(BTN_THUMBL);
	case STR(BTN_THUMBR);
	case STR(BTN_TOOL_PEN);
	case STR(BTN_TOOL_RUBBER);
	case STR(BTN_TOOL_BRUSH);
	case STR(BTN_TOOL_PENCIL);
	case STR(BTN_TOOL_AIRBRUSH);
	case STR(BTN_TOOL_FINGER);
	case STR(BTN_TOOL_MOUSE);
	case STR(BTN_TOOL_LENS);
	case STR(BTN_TOUCH);
	case STR(BTN_STYLUS);
	case STR(BTN_STYLUS2);
	case STR(BTN_TOOL_DOUBLETAP);
	case STR(BTN_TOOL_TRIPLETAP);
	case STR(BTN_TOOL_QUADTAP);
	case STR(BTN_GEAR_DOWN);
	case STR(BTN_GEAR_UP);
	case STR(KEY_OK);
	case STR(KEY_SELECT);
	case STR(KEY_GOTO);
	case STR(KEY_CLEAR);
	case STR(KEY_POWER2);
	case STR(KEY_OPTION);
	case STR(KEY_INFO);
	case STR(KEY_TIME);
	case STR(KEY_VENDOR);
	case STR(KEY_ARCHIVE);
	case STR(KEY_PROGRAM);
	case STR(KEY_CHANNEL);
	case STR(KEY_FAVORITES);
	case STR(KEY_EPG);
	case STR(KEY_PVR);
	case STR(KEY_MHP);
	case STR(KEY_LANGUAGE);
	case STR(KEY_TITLE);
	case STR(KEY_SUBTITLE);
	case STR(KEY_ANGLE);
	case STR(KEY_ZOOM);
	case STR(KEY_MODE);
	case STR(KEY_KEYBOARD);
	case STR(KEY_SCREEN);
	case STR(KEY_PC);
	case STR(KEY_TV);
	case STR(KEY_TV2);
	case STR(KEY_VCR);
	case STR(KEY_VCR2);
	case STR(KEY_SAT);
	case STR(KEY_SAT2);
	case STR(KEY_CD);
	case STR(KEY_TAPE);
	case STR(KEY_RADIO);
	case STR(KEY_TUNER);
	case STR(KEY_PLAYER);
	case STR(KEY_TEXT);
	case STR(KEY_DVD);
	case STR(KEY_AUX);
	case STR(KEY_MP3);
	case STR(KEY_AUDIO);
	case STR(KEY_VIDEO);
	case STR(KEY_DIRECTORY);
	case STR(KEY_LIST);
	case STR(KEY_MEMO);
	case STR(KEY_CALENDAR);
	case STR(KEY_RED);
	case STR(KEY_GREEN);
	case STR(KEY_YELLOW);
	case STR(KEY_BLUE);
	case STR(KEY_CHANNELUP);
	case STR(KEY_CHANNELDOWN);
	case STR(KEY_FIRST);
	case STR(KEY_LAST);
	case STR(KEY_AB);
	case STR(KEY_NEXT);
	case STR(KEY_RESTART);
	case STR(KEY_SLOW);
	case STR(KEY_SHUFFLE);
	case STR(KEY_BREAK);
	case STR(KEY_PREVIOUS);
	case STR(KEY_DIGITS);
	case STR(KEY_TEEN);
	case STR(KEY_TWEN);
	case STR(KEY_VIDEOPHONE);
	case STR(KEY_GAMES);
	case STR(KEY_ZOOMIN);
	case STR(KEY_ZOOMOUT);
	case STR(KEY_ZOOMRESET);
	case STR(KEY_WORDPROCESSOR);
	case STR(KEY_EDITOR);
	case STR(KEY_SPREADSHEET);
	case STR(KEY_GRAPHICSEDITOR);
	case STR(KEY_PRESENTATION);
	case STR(KEY_DATABASE);
	case STR(KEY_NEWS);
	case STR(KEY_VOICEMAIL);
	case STR(KEY_ADDRESSBOOK);
	case STR(KEY_MESSENGER);
	case STR(KEY_DISPLAYTOGGLE);
	case STR(KEY_SPELLCHECK);
	case STR(KEY_LOGOFF);
	case STR(KEY_DOLLAR);
	case STR(KEY_EURO);
	case STR(KEY_FRAMEBACK);
	case STR(KEY_FRAMEFORWARD);
	case STR(KEY_CONTEXT_MENU);
	case STR(KEY_MEDIA_REPEAT);
	case STR(KEY_DEL_EOL);
	case STR(KEY_DEL_EOS);
	case STR(KEY_INS_LINE);
	case STR(KEY_DEL_LINE);
	case STR(KEY_FN);
	case STR(KEY_FN_ESC);
	case STR(KEY_FN_F1);
	case STR(KEY_FN_F2);
	case STR(KEY_FN_F3);
	case STR(KEY_FN_F4);
	case STR(KEY_FN_F5);
	case STR(KEY_FN_F6);
	case STR(KEY_FN_F7);
	case STR(KEY_FN_F8);
	case STR(KEY_FN_F9);
	case STR(KEY_FN_F10);
	case STR(KEY_FN_F11);
	case STR(KEY_FN_F12);
	case STR(KEY_FN_1);
	case STR(KEY_FN_2);
	case STR(KEY_FN_D);
	case STR(KEY_FN_E);
	case STR(KEY_FN_F);
	case STR(KEY_FN_S);
	case STR(KEY_FN_B);
	case STR(KEY_BRL_DOT1);
	case STR(KEY_BRL_DOT2);
	case STR(KEY_BRL_DOT3);
	case STR(KEY_BRL_DOT4);
	case STR(KEY_BRL_DOT5);
	case STR(KEY_BRL_DOT6);
	case STR(KEY_BRL_DOT7);
	case STR(KEY_BRL_DOT8);
	case STR(KEY_BRL_DOT9);
	case STR(KEY_BRL_DOT10);
	case STR(KEY_NUMERIC_0);
	case STR(KEY_NUMERIC_1);
	case STR(KEY_NUMERIC_2);
	case STR(KEY_NUMERIC_3);
	case STR(KEY_NUMERIC_4);
	case STR(KEY_NUMERIC_5);
	case STR(KEY_NUMERIC_6);
	case STR(KEY_NUMERIC_7);
	case STR(KEY_NUMERIC_8);
	case STR(KEY_NUMERIC_9);
	case STR(KEY_NUMERIC_STAR);
	case STR(KEY_NUMERIC_POUND);
	case STR(KEY_CAMERA_FOCUS);
	default: return int2str(code);
	}
#undef STR
}

static const char *rel_code(int code)
{
#define STR(N) N: return #N
	switch (code) {
	case STR(REL_X);
	case STR(REL_Y);
	case STR(REL_Z);
	case STR(REL_RX);
	case STR(REL_RY);
	case STR(REL_RZ);
	case STR(REL_HWHEEL);
	case STR(REL_DIAL);
	case STR(REL_WHEEL);
	case STR(REL_MISC);
	default: return int2str(code);
	}
#undef STR
}

static const char *abs_code(int code)
{
#define STR(N) N: return #N
	switch (code) {
	case STR(ABS_X);
	case STR(ABS_Y);
	case STR(ABS_Z);
	case STR(ABS_RX);
	case STR(ABS_RY);
	case STR(ABS_RZ);
	case STR(ABS_THROTTLE);
	case STR(ABS_RUDDER);
	case STR(ABS_WHEEL);
	case STR(ABS_GAS);
	case STR(ABS_BRAKE);
	case STR(ABS_HAT0X);
	case STR(ABS_HAT0Y);
	case STR(ABS_HAT1X);
	case STR(ABS_HAT1Y);
	case STR(ABS_HAT2X);
	case STR(ABS_HAT2Y);
	case STR(ABS_HAT3X);
	case STR(ABS_HAT3Y);
	case STR(ABS_PRESSURE);
	case STR(ABS_DISTANCE);
	case STR(ABS_TILT_X);
	case STR(ABS_TILT_Y);
	case STR(ABS_TOOL_WIDTH);
	case STR(ABS_VOLUME);
	case STR(ABS_MISC);
	case STR(ABS_MT_TOUCH_MAJOR);
	case STR(ABS_MT_TOUCH_MINOR);
	case STR(ABS_MT_WIDTH_MAJOR);
	case STR(ABS_MT_WIDTH_MINOR);
	case STR(ABS_MT_ORIENTATION);
	case STR(ABS_MT_POSITION_X);
	case STR(ABS_MT_POSITION_Y);
	case STR(ABS_MT_TOOL_TYPE);
	case STR(ABS_MT_BLOB_ID);
	case STR(ABS_MT_TRACKING_ID);
	case STR(ABS_MT_PRESSURE);
	default: return int2str(code);
	}
#undef STR
}

static const char *evcode(struct input_event *e)
{
#define STR(N) N: return #N
	switch (e->type) {
	case EV_SYN:
		return syn_code(e->code);
	case EV_KEY:
		return key_code(e->code);
	case EV_REL:
		return rel_code(e->code);
	case EV_ABS:
		return abs_code(e->code);
	default:
		return int2str(e->code);
	}
#undef STR
}

static const char *evvval(struct input_event *e)
{
	if (e->type == EV_ABS && e->code == ABS_X) {
		uint16_t val = e->value;
		uint8_t val0 = val & 0xff;
		uint8_t val1 = val >> 8;
		uint16_t val2 = val0 << 8 | val1;
		printf("val=%04x val0=%02x val1=%02x val2=%04x (%i vs. %i)\n", val, val0, val1, val2, val, val2);
	}
	return int2str(e->value);
}

int main(int argc, char **argv)
{

	int i, fd = -1;              /* the file descriptor for the device */
	size_t read_bytes;           /* how many bytes were read */
	struct input_event ev[64];   /* the events (up to 64 at once) */

	if (argc != 2) {
		fprintf(stderr, "usage: %s event-device - probably /dev/input/evdev0\n",
				argv[0]);
		exit(1);
	}

	if ((fd = open(argv[1], O_RDONLY)) < 0) {
		perror("evdev open");
		exit(1);
	}

	while (1) {
		read_bytes = read(fd, ev, sizeof(struct input_event) * 64);

		if (read_bytes < (int)sizeof(struct input_event)) {
			perror("evtest: short read");
			exit (1);
		}

		for (i = 0; i < (int) (read_bytes / sizeof(struct input_event)); i++) {
			printf("Event: time %ld.%06ld, type %s, code %s, value %s\n",
					ev[i].time.tv_sec, ev[i].time.tv_usec,
					evtype(&ev[i]),
					evcode(&ev[i]),
					evvval(&ev[i])
			      );
		}
	}

	close(fd);

	exit(0);
}
