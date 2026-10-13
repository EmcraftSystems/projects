/*
 * LVGL v9 configuration for the i.MX RT demos. Options not set here keep
 * the defaults from lvgl/include/lvgl/config/lv_conf_internal.h.
 */

#ifndef LV_CONF_H
#define LV_CONF_H

#define LV_COLOR_FORMAT_DEFAULT		LV_COLOR_FORMAT_RGB565

#define LV_USE_STDLIB_MALLOC		LV_STDLIB_CLIB

#define LV_DEF_REFR_PERIOD		40

#define LV_USE_LINUX_FBDEV		1
#define LV_USE_EVDEV			1

#define LV_FONT_MONTSERRAT_12		1
#define LV_FONT_MONTSERRAT_14		1
#define LV_FONT_MONTSERRAT_16		1
/* Required by lv_demo_benchmark */
#define LV_FONT_MONTSERRAT_20		1
#define LV_FONT_MONTSERRAT_24		1
#define LV_FONT_MONTSERRAT_26		1

#define LV_USE_DEMO_WIDGETS		1
#define LV_USE_DEMO_BENCHMARK		1
#define LV_USE_DEMO_STRESS		1
#define LV_USE_DEMO_MUSIC		1

/* lv_demo_benchmark takes its results from the performance monitor */
#define LV_USE_SYSMON			1
#define LV_USE_PERF_MONITOR		1

/*
 * Size: drop what none of the demos uses. The benchmark brings its own
 * aligned fonts; the demos' images are RGB565, RGB565A8, RGB888,
 * XRGB8888 and ARGB8888.
 */
#define LV_FONT_MONTSERRAT_14_ALIGNED	0
#define LV_USE_THEME_MONO		0

#define LV_USE_ANIMIMG			0
#define LV_USE_ARCLABEL			0
#define LV_USE_CANVAS			0
#define LV_USE_LED			0
#define LV_USE_MENU			0
#define LV_USE_SPAN			0
#define LV_USE_SPINNER			0

#define LV_DRAW_SW_SUPPORT_RGB565_SWAPPED	0
#define LV_DRAW_SW_SUPPORT_L8		0
#define LV_DRAW_SW_SUPPORT_AL88		0
#define LV_DRAW_SW_SUPPORT_I1		0

#endif /* LV_CONF_H */
