/*
    Copyright 2022 natinusala

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

#include <skia_loftwing/include/c/gr_context.h>
#include <skia_loftwing/include/c/sk_types.h>
#include <skia_loftwing/include/c/sk_canvas.h>
#include <skia_loftwing/include/c/sk_surface.h>
#include <skia_loftwing/include/c/sk_colorspace.h>
#include <skia_loftwing/include/c/sk_paint.h>
#include <skia_loftwing/include/c/sk_image.h>
#include <skia_loftwing/include/c/sk_bitmap.h>
#include <skia_loftwing/include/c/sk_pixmap.h>
#include <skia_loftwing/include/c/sk_shader.h>
#include <skia_loftwing/include/c/sk_matrix.h>
#include <skia_loftwing/include/c/sk_font.h>
#include <skia_loftwing/include/c/sk_typeface.h>
#include <skia_loftwing/include/c/sk_data.h>

static const uint32_t kAll_GrBackendState = 0xffffffff;
