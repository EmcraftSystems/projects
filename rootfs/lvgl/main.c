/* LVGL demo application */

#include <unistd.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <pthread.h>
#include <linux/input.h>

#include "lvgl/lvgl.h"
#include "lvgl/demos/lv_demos.h"
#include "lv_drivers/display/fbdev.h"
#include "lv_drivers/indev/evdev.h"


#if defined(BUILD_DEMO_EBIKE)
#include "ebike_ui/ui.h"

pthread_mutex_t button_mutex = PTHREAD_MUTEX_INITIALIZER;
int button_pressed = 0;
uint64_t button_last_updated = 0;

#define BUTTON_EVDEV "/dev/input/event1"
#define BUTTON_KEY KEY_A

void * button_thread (void *args);
void update_screen(lv_timer_t * timer);

/* Update widgets according to current speed */
void update_screen(__attribute__((__unused__)) lv_timer_t * timer)
{
	time_t rawtime;
	struct tm * timeinfo;
	static int min_prev = -1;
	static int speed = 0;
	static int speed_prev = 0;
	static int speed_max = 0;
	int speed_avg = 0;
	struct timespec tm;
	uint64_t now_ms;
	static uint64_t prev_ms = 0;
	uint32_t accel_s;
	static uint32_t cnt = 0;
	static uint64_t odo = 0;
	uint64_t odo_print;
	const uint32_t odo_base = 2877;
	static uint64_t trip = 0;
	uint64_t trip_print;
	static uint64_t trip_ms = 0;
	const uint32_t trip_max = (5 * 60 * 60 * 1000);
	uint64_t time_ms;
	static int bat_prev = -1;
	int bat;

	/* print time in the upper right corner of the screen */
	time ( &rawtime );
	timeinfo = localtime ( &rawtime );
	if (min_prev != timeinfo->tm_min) {
		lv_label_set_text_fmt(ui_Label_Time, "%02d:%02d", timeinfo->tm_hour % 12, timeinfo->tm_min);
		if (timeinfo->tm_hour / 12 > 0)
			lv_label_set_text(ui_LabeL_PM, "PM");
		else
			lv_label_set_text(ui_LabeL_PM, "AM");
		min_prev = timeinfo->tm_min;
	}

	clock_gettime(CLOCK_MONOTONIC, &tm);
	now_ms = ((uint64_t)tm.tv_sec * 1000) + (tm.tv_nsec / 1000000);

	/* calculate speed */
	pthread_mutex_lock(&button_mutex);
	if ((now_ms - button_last_updated) < LV_DISP_DEF_REFR_PERIOD) {
		/* reset the accelerator is the user button has just been pressed */
		cnt = 0;
	}
	accel_s = (now_ms - button_last_updated) / 1000;
	if (button_pressed && (speed < 99)) {
		/* apply dynamic acceleration which grows over time */
		if (accel_s > 6 || (cnt % (1 << (6 - accel_s)) == 0)) {
			speed ++;
		}
	} else if (!button_pressed && (speed > 0)) {
		/* apply dynamic de-acceleration which grows (in absolute values) over time */
		if (accel_s > 6 || (cnt % (1 << (6 - accel_s)) == 0)) {
			speed --;
		}
	}
	cnt ++;
	pthread_mutex_unlock(&button_mutex);

	/* update the odometer, trip etc. lables */
	if (prev_ms != 0 && speed > 0) {
		if (speed_prev == 0 || trip >= (trip_max)) {
			trip = 0;
			speed_max = 0;
			trip_ms = prev_ms;
		}

		odo += (uint64_t) speed * (now_ms - prev_ms);
		odo_print = odo / 100 / 60 / 60 + odo_base;
		lv_label_set_text_fmt(ui_Label_ODO_Number, "%d.%d", (int)(odo_print / 10), (int) (odo_print % 10));

		trip += (uint64_t) speed * (now_ms - prev_ms);
		trip_print = trip / 100 / 60 / 60;
		lv_label_set_text_fmt(ui_Label_Trip_Number, "%d.%d", (int)(trip_print / 10), (int) (trip_print % 10));

		if (speed > speed_max) {
			speed_max = speed;
			lv_label_set_text_fmt(ui_Label_Max_Speed_Number, "%d.%d", speed_max, 0);
		}

		speed_avg = (trip * 10) / (now_ms - trip_ms);
		lv_label_set_text_fmt(ui_Label_AVG_Speed_Number, "%d.%d", speed_avg / 10, speed_avg % 10);

		time_ms = now_ms - trip_ms;
		lv_label_set_text_fmt(ui_Label_Arrival_Time_Number1,
				      "%02d:%02d:%02d",
				      (int)time_ms / 1000 / 60, ((int)time_ms / 1000) % 60, ((int)time_ms / 10) % 100);

		if (trip <= trip_max) {
			time_ms = ((trip_max - trip) * 10) / (speed_avg);
			lv_label_set_text_fmt(ui_Label_ETA_Number,
					      "%02d:%02d:%02d",
					      ((int)time_ms / 1000 / 60 / 60) % 60,
					      ((int)time_ms / 1000 / 60) % 60, ((int)time_ms / 1000) % 60);
		}
	}

	/* update the speed silder and labels */
	if (speed_prev != speed) {
		lv_slider_set_value(ui_Slider_Speed, speed, LV_ANIM_OFF);

		lv_label_set_text_fmt(ui_Speed_Number_1, "%02d", speed);
		lv_label_set_text_fmt(ui_Speed_Number_2, "%02d", speed);
		speed_prev = speed;
	}


	/* update the battery lable as per the corresponding slider value */
	bat = lv_slider_get_value(ui_Slider_Battery);

	if (bat != bat_prev) {
		lv_label_set_text_fmt(ui_Label_Battery_Number, "%d", bat);
		bat_prev = bat;
	}

	prev_ms = now_ms;
}

/* thread to monitor User Button state used to calculate an acceleration */
void * button_thread (__attribute__((__unused__)) void *args)
{
	int fd = -1;              /* the file descriptor for the device */
	size_t read_bytes;           /* how many bytes were read */
	struct input_event ev;   /* the events (up to 64 at once) */
	struct timespec tm;

	if ((fd = open(BUTTON_EVDEV, O_RDONLY)) < 0) {
		perror("evdev open");
		exit (1);
	}

	button_last_updated = ((uint64_t)tm.tv_sec * 1000) + (tm.tv_nsec / 1000000);

	while (1) {
		read_bytes = read(fd, &ev, sizeof(struct input_event));

		if (read_bytes < (int)sizeof(struct input_event)) {
			perror("evdev: short read");
			exit (1);
		}

		if (ev.type == EV_KEY && ev.code == BUTTON_KEY) {
			clock_gettime(CLOCK_MONOTONIC, &tm);

			pthread_mutex_lock(&button_mutex);
			button_last_updated = ((uint64_t)tm.tv_sec * 1000) + (tm.tv_nsec / 1000000);
			if (ev.value == 1) {
				button_pressed = 1;
			} else {
				button_pressed = 0;
			}
			pthread_mutex_unlock(&button_mutex);
		}
	}

	close(fd);

	return NULL;
}
#endif /* BUILD_DEMO_EBIKE */

int main(void)
{
	uint32_t xres, yres;

	/* LittlevGL init */
	lv_init();

	/* Linux frame buffer device init */
	fbdev_init();

	fbdev_get_sizes(&xres, &yres, NULL);

	/* A small buffer for LittlevGL to draw the screen's content */
	static lv_color_t *buf;
	buf = malloc((xres * yres * sizeof(lv_color_t)) / 8);
	/* Initialize a descriptor for the buffer */
	static lv_disp_draw_buf_t disp_buf;
	lv_disp_draw_buf_init(&disp_buf, buf, NULL, xres * yres / 8);

	/* Initialize and register a display driver */
	static lv_disp_drv_t disp_drv;
	lv_disp_drv_init(&disp_drv);
	disp_drv.draw_buf   = &disp_buf;
	disp_drv.flush_cb   = fbdev_flush;
	disp_drv.hor_res    = xres;
	disp_drv.ver_res    = yres;
	lv_disp_drv_register(&disp_drv);

	evdev_init();
	static lv_indev_drv_t indev_drv;

	lv_indev_drv_init(&indev_drv); /* Basic initialization */
	indev_drv.type = LV_INDEV_TYPE_POINTER;

	/* This function will be called periodically (by the library) to get the mouse position and state */
	indev_drv.read_cb = evdev_read;
	lv_indev_drv_register(&indev_drv);

	/* Create a Demo */
#if defined(BUILD_DEMO_STRESS)
	lv_demo_stress();
#elif defined(BUILD_DEMO_BENCHMARK)
	lv_demo_benchmark();
#elif defined(BUILD_DEMO_WIDGETS)
	lv_demo_widgets();
#elif defined(BUILD_DEMO_MUSIC)
	lv_demo_music();
#elif defined(BUILD_DEMO_EBIKE)
	int s;
	pthread_attr_t attr;
	pthread_t thread_id;        /* ID returned by pthread_create() */

	s = pthread_attr_init(&attr);
	if (s != 0) {
		perror("pthread_attr_init");
		exit(-1);
	}
	s = pthread_create(&thread_id, &attr,
			   &button_thread, NULL);
	if (s != 0) {
		perror("pthread_create");
		exit(-1);
	}

	ui_init();
	lv_timer_create(update_screen, LV_DISP_DEF_REFR_PERIOD, NULL);

#endif

	/* Handle LitlevGL tasks (tickless mode) */
	while (1) {
		uint64_t now_ms;
		uint64_t post_ms;
		uint32_t time_ms;
		struct timespec tm;

		clock_gettime(CLOCK_MONOTONIC, &tm);
		now_ms = ((uint64_t)tm.tv_sec * 1000) + (tm.tv_nsec / 1000000);

		lv_timer_handler();

		clock_gettime(CLOCK_MONOTONIC, &tm);
		post_ms = ((uint64_t)tm.tv_sec * 1000) + (tm.tv_nsec / 1000000);

		if (post_ms - now_ms < LV_DISP_DEF_REFR_PERIOD) {
			  time_ms = LV_DISP_DEF_REFR_PERIOD - (post_ms - now_ms);
			  usleep(time_ms * 1000);
		}

	}

	return 0;
}

/* Set in lv_conf.h as `LV_TICK_CUSTOM_SYS_TIME_EXPR` */
uint32_t custom_tick_get(void)
{
	static uint64_t start_ms = 0;
	struct timespec tm;
	uint64_t now_ms;
	uint32_t time_ms;

	if(start_ms == 0) {
		clock_gettime(CLOCK_MONOTONIC, &tm);
		start_ms = ((uint64_t)tm.tv_sec * 1000) + (tm.tv_nsec / 1000000);
	}


	clock_gettime(CLOCK_MONOTONIC, &tm);
	now_ms = ((uint64_t)tm.tv_sec * 1000) + (tm.tv_nsec / 1000000);

	time_ms = now_ms - start_ms;
	return time_ms;
}
