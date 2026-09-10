/*
 * Copyright 2007, Crank Software Inc. All Rights Reserved.
 *
 * For more information email info@cranksoftware.com.
 *
 * Example for handling GREIO events from GAPP aplication.
 * Copyright 2017, Emcraft Systems.
 */

/**
 * This is a sample application that receives messages from the engine
 * and blinks LEDs.
 *
 * It uses IO interface API to receive the events
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <libgen.h>
#include <gre/greio.h>


/*#define DEBUG 1*/

struct event {
	char *name;
	int revent;
};

enum revents {
	LED_BLINK = 1,
	LED_STOPBLINK,
	SOUND_VOLUME,
	SOUND_PLAY,
	SOUND_STOP,
	SOUND_DEFAULT,
	BACKLIGHT
};

static struct event myevents[] = {
	{"blink_led", LED_BLINK},
	{"stop_blink", LED_STOPBLINK},
	{"volume", SOUND_VOLUME},
	{"audio_play", SOUND_PLAY},
	{"audio_stop", SOUND_STOP},
	{"audio_default", SOUND_DEFAULT},
	{"set_brightness", BACKLIGHT},
	{NULL, 0}
};


int main(int argc, char **argv) {
    gre_io_t                 *send_handle;
    gre_io_t                 *recv_handle;
    gre_io_serialized_data_t      *buffer = NULL;
    int ret;
    char                   *revent_name = NULL;
    char                   *revent_target = NULL;
    char                   *revent_format = NULL;
    uint8_t                *revent_data = NULL;
    int                    rnbytes;
    char                   *path;

    if (argc == 1) {
	    printf("Usage: %s <sample WAV file to play>\n", argv[0]);
	    exit(-1);
    }
    /* Find the path to scripts, the same dir as for the .wav file */
    path = dirname(strdup(argv[1]));

    send_handle = gre_io_open("lcd_demo.gapp", GRE_IO_TYPE_WRONLY);
    if(send_handle == NULL) {
        printf("Can't open send handle\n");
        return 0;
    }

    recv_handle = gre_io_open("crank_channel", GRE_IO_TYPE_RDONLY);
    if(recv_handle == NULL) {
        printf("Can't open recv handle\n");
        return 0;
    }

    while(1) {
        char cmd[512];
	struct event *ev;
#if DEBUG
	printf("Waiting for event...\n");
#endif
        ret = gre_io_receive(recv_handle, &buffer);
        if(ret < 0) {
            printf("Problem receiving data on channel\n");
            break;
        }

	memset(cmd, 0, sizeof(cmd));
        rnbytes = gre_io_unserialize(buffer, &revent_target,
                    &revent_name, &revent_format, (void **)&revent_data);
#if DEBUG
	printf("Got %d bytes, event %s, format %s, target %s, data %s\n",
		rnbytes, *revent_name ? revent_name: "NULL",
		*revent_format ? revent_format : "NULL",
		*revent_target ? revent_target : "NULL",
		*revent_data ? (char *)revent_data : "NULL");
#endif
	for (ev = myevents; ev->revent; ev++) {
		if (!strcmp(ev->name, (char *)revent_name))
			break;
	}
	if (!ev->revent) {
		printf("Unknown event %s, continue\n", revent_name);
		continue;
	}

	switch(ev->revent) {
	case LED_BLINK:
		if (!strcmp(revent_target, "DS1") && *revent_data) {
			sprintf(cmd, "%s/blinkled.sh DS1 %s &", path, revent_data);
		}
		if (!strcmp(revent_target, "DS2") && *revent_data) {
			sprintf(cmd, "%s/blinkled.sh DS2 %s &", path, revent_data);
		}
		break;
	case LED_STOPBLINK:
		sprintf(cmd, "killall blinkled.sh");
		break;
	case SOUND_VOLUME:
		if (!strcmp(revent_target, "left")) {
			sprintf(cmd, "amixer -q sset 'Headphone' frontleft,%s%%", revent_data);
		}
		if (!strcmp(revent_target, "right")) {
			sprintf(cmd, "amixer -q sset 'Headphone' frontright,%s%%", revent_data);
		}
		break;
	case SOUND_DEFAULT:
		break;
	case SOUND_PLAY:
		sprintf(cmd, "%s/playsound.sh %s &", path, argv[1]);
		break;
	case SOUND_STOP:
		sprintf(cmd, "killall playsound.sh");
		break;
	case BACKLIGHT:
		sprintf(cmd, "%s/backlight.sh %s", path, revent_data);
		break;
	default:
		printf("Unknown cmd %d, continue\n", ev->revent);
		continue;
	}

	if (*cmd) {
#if DEBUG
		printf(cmd);
		printf("\n");
#endif
		system(cmd);
	}
    }

    return 1;
}
