///*****************************************************************************
//*
//* Copyright (C) 2012 Ittiam Systems Pvt Ltd, Bangalore
//*
//* Licensed under the Apache License, Version 2.0 (the "License");
//* you may not use this file except in compliance with the License.
//* You may obtain a copy of the License at:
//*
//* http://www.apache.org/licenses/LICENSE-2.0
//*
//* Unless required by applicable law or agreed to in writing, software
//* distributed under the License is distributed on an "AS IS" BASIS,
//* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//* See the License for the specific language governing permissions and
//* limitations under the License.
//*
//*****************************************************************************/
///**
//******************************************************************************
//* //file
//*  ihevc_inter_pred_filters_luma_vert_w16inp.s
//*
//* //brief
//*  contains function definitions for inter prediction  interpolation.
//* functions are coded using neon  intrinsics and can be compiled using

//* rvct
//*
//* //author
//*  yogeswaran rs
//*
//* //par list of functions:
//*
//*  - ihevc_inter_pred_filters_luma_vert_w16inp()
//*
//* //remarks
//*  none
//*
//*******************************************************************************
//*/

///* all the functions here are replicated from ihevc_inter_pred_filters.c and modified to */
///* include reconstruction */
//

///**
//*******************************************************************************
//*
//* //brief
//*    luma vertical filter for 16bit input.
//*
//* //par description:
//*     applies a vertical filter with coefficients pointed to  by 'pi1_coeff' to
//*     the elements pointed by 'pu1_src' and  writes to the location pointed by
//*    'pu1_dst'  input is 16 bits  the filter output is downshifted by 12 and
//*     clipped to lie  between 0 and 255   assumptions : the function is
//*     optimized considering the fact width is  multiple of 4. and height as
//*     multiple of 2.
//*
//* //param[in] pi2_src
//*  word16 pointer to the source
//*
//* //param[out] pu1_dst
//*  uword8 pointer to the destination
//*
//* //param[in] src_strd
//*  integer source stride
//*
//* //param[in] dst_strd
//*  integer destination stride
//*
//* //param[in] pi1_coeff
//*  word8 pointer to the filter coefficients
//*
//* //param[in] ht
//*  integer height of the array
//*
//* //param[in] wd
//*  integer width of the array
//*
//* //returns
//*
//* //remarks
//*  none
//*
//*******************************************************************************
//*/

//void ihevc_inter_pred_luma_vert_w16inp(word16 *pi2_src,
//                                    uword8 *pu1_dst,
//                                    word32 src_strd,
//                                    word32 dst_strd,
//                                    word8 *pi1_coeff,
//                                    word32 ht,
//                                    word32 wd   )

.text
.align 4

.include "ihevc_neon_macros.s"

.globl ihevc_inter_pred_luma_vert_w16inp_av8

.type ihevc_inter_pred_luma_vert_w16inp_av8, %function

ihevc_inter_pred_luma_vert_w16inp_av8:

    // stmfd sp!, {x4-x12, x14}    //stack stores the values of the arguments

    stp         x19, x20,[sp,#-16]!

    mov         x15,x4 // pi1_coeff
    mov         x16,x5 // ht
    mov         x17,x6 // wd

    mov         x12,x15                     //load pi1_coeff
    mov         x6,x3
    mov         x5,x17                      //load wd
    ld1         {v0.8b},[x12]               //coeff = vld1_s8(pi1_coeff)
    lsl         x2, x2, #1
    sub         x12,x2,x2,lsl #2            //src_ctrd & pi1_coeff
    //abs  v0.8b, v0.8b                //vabs_s8(coeff)
    add         x0,x0,x12                   //x0->pu1_src    x12->pi1_coeff
    mov         x3,x16                      //load ht
    subs        x7,x3,#0                    //x3->ht
    //ble          end_loops            //end loop jump
    sxtl        v0.8h, v0.8b
    dup         v22.4h, v0.4h[0]            //coeffabs_0 = vdup_lane_u8(coeffabs, 0)//
    dup         v23.4h, v0.4h[1]            //coeffabs_1 = vdup_lane_u8(coeffabs, 1)//
    dup         v24.4h, v0.4h[2]            //coeffabs_2 = vdup_lane_u8(coeffabs, 2)//
    dup         v25.4h, v0.4h[3]            //coeffabs_3 = vdup_lane_u8(coeffabs, 3)//
    dup         v26.4h, v0.4h[4]            //coeffabs_4 = vdup_lane_u8(coeffabs, 4)//
    dup         v27.4h, v0.4h[5]            //coeffabs_5 = vdup_lane_u8(coeffabs, 5)//
    dup         v28.4h, v0.4h[6]            //coeffabs_6 = vdup_lane_u8(coeffabs, 6)//
    dup         v29.4h, v0.4h[7]            //coeffabs_7 = vdup_lane_u8(coeffabs, 7)//

    sub         x20,x5,x6,lsl #2            //x6->dst_strd    x5    ->wd
    neg         x9, x20
    sub         x20,x5,x2,lsl #2            //x2->src_strd
    neg         x8, x20
    sub         x8,x8,x5
    lsr         x3, x5, #2                  //divide by 4
    mul         x7, x7, x3                  //multiply height by width
    sub         x7, x7,#4                   //subtract by one for epilog
    mov         x4,x5                       //x5 ->wd
    //lsl x2, x2, #1

prolog:

    add         x3,x0,x2                    //pu1_src_tmp += src_strd//
    ld1         {v1.4h},[x3],x2             //src_tmp2 = vld1_u8(pu1_src_tmp)//
    ld1         {v0.4h},[x0],#8             //src_tmp1 = vld1_u8(pu1_src_tmp)//
    subs        x4,x4,#4
    ld1         {v2.4h},[x3],x2             //src_tmp3 = vld1_u8(pu1_src_tmp)//
    smull       v19.4s, v1.4h, v23.4h       //mul_res1 = vmull_u8(src_tmp2, coeffabs_1)//
    ld1         {v3.4h},[x3],x2             //src_tmp4 = vld1_u8(pu1_src_tmp)//
    smlal       v19.4s, v0.4h, v22.4h       //mul_res1 = vmlal_u8(mul_res1, src_tmp1, coeffabs_0)//
    ld1         {v4.4h},[x3],x2             //src_tmp1 = vld1_u8(pu1_src_tmp)//
    smlal       v19.4s, v2.4h, v24.4h       //mul_res1 = vmlal_u8(mul_res1, src_tmp3, coeffabs_2)//
    ld1         {v5.4h},[x3],x2             //src_tmp2 = vld1_u8(pu1_src_tmp)//
    smlal       v19.4s, v3.4h, v25.4h       //mul_res1 = vmlal_u8(mul_res1, src_tmp4, coeffabs_3)//
    ld1         {v6.4h},[x3],x2             //src_tmp3 = vld1_u8(pu1_src_tmp)//
    smlal       v19.4s, v4.4h, v26.4h       //mul_res1 = vmlal_u8(mul_res1, src_tmp1, coeffabs_4)//
    ld1         {v7.4h},[x3],x2             //src_tmp4 = vld1_u8(pu1_src_tmp)//
    smlal       v19.4s, v5.4h, v27.4h       //mul_res1 = vmlal_u8(mul_res1, src_tmp2, coeffabs_5)//
    smlal       v19.4s, v6.4h, v28.4h       //mul_res1 = vmlal_u8(mul_res1, src_tmp3, coeffabs_6)//
    smlal       v19.4s, v7.4h, v29.4h       //mul_res1 = vmlal_u8(mul_res1, src_tmp4, coeffabs_7)//

    ld1         {v16.4h},[x3],x2            //src_tmp1 = vld1_u8(pu1_src_tmp)//

    smull       v20.4s, v2.4h, v23.4h       //mul_res2 = vmull_u8(src_tmp3, coeffabs_1)//
    add         x20,x0,x8,lsl #0
    csel        x0, x20, x0,le
    smlal       v20.4s, v1.4h, v22.4h       //mul_res2 = vmlal_u8(mul_res2, src_tmp2, coeffabs_0)//
    csel        x4, x5, x4,le               //x5 ->wd
    smlal       v20.4s, v3.4h, v24.4h       //mul_res2 = vmlal_u8(mul_res2, src_tmp4, coeffabs_2)//
    ld1         {v17.4h},[x3],x2            //src_tmp2 = vld1_u8(pu1_src_tmp)//
    smlal       v20.4s, v4.4h, v25.4h       //mul_res2 = vmlal_u8(mul_res2, src_tmp1, coeffabs_3)//
    ld1         {v18.4h},[x3],x2            //src_tmp3 = vld1_u8(pu1_src_tmp)//
    smlal       v20.4s, v5.4h, v26.4h       //mul_res2 = vmlal_u8(mul_res2, src_tmp2, coeffabs_4)//
    add         x3,x0,x2                    //pu1_src_tmp += src_strd//
    smlal       v20.4s, v6.4h, v27.4h       //mul_res2 = vmlal_u8(mul_res2, src_tmp3, coeffabs_5)//
    smlal       v20.4s, v7.4h, v28.4h       //mul_res2 = vmlal_u8(mul_res2, src_tmp4, coeffabs_6)//
    smlal       v20.4s, v16.4h, v29.4h      //mul_res2 = vmlal_u8(mul_res2, src_tmp1, coeffabs_7)//
    sqshrn      v19.4h, v19.4s,#6

    ld1         {v1.4h},[x3],x2             //src_tmp3 = vld1_u8(pu1_src_tmp)//
    smull       v21.4s, v3.4h, v23.4h
    ld1         {v0.4h},[x0],#8             //src_tmp1 = vld1_u8(pu1_src_tmp)//
    smlal       v21.4s, v2.4h, v22.4h
    ld1         {v2.4h},[x3],x2             //src_tmp3 = vld1_u8(pu1_src_tmp)//
    smlal       v21.4s, v4.4h, v24.4h
    smlal       v21.4s, v5.4h, v25.4h
    smlal       v21.4s, v6.4h, v26.4h
    smlal       v21.4s, v7.4h, v27.4h
    smlal       v21.4s, v16.4h, v28.4h
    smlal       v21.4s, v17.4h, v29.4h
    add         x14,x1,x6
    sqshrn      v20.4h, v20.4s,#6
    sqrshrun    v19.8b, v19.8h,#6           //sto_res = vqmovun_s16(sto_res_tmp)//

    smull       v30.4s, v4.4h, v23.4h
    smlal       v30.4s, v3.4h, v22.4h
    smlal       v30.4s, v5.4h, v24.4h
    smlal       v30.4s, v6.4h, v25.4h
    ld1         {v3.4h},[x3],x2             //src_tmp4 = vld1_u8(pu1_src_tmp)//
    smlal       v30.4s, v7.4h, v26.4h
    ld1         {v4.4h},[x3],x2             //src_tmp1 = vld1_u8(pu1_src_tmp)//
    smlal       v30.4s, v16.4h, v27.4h
    ld1         {v5.4h},[x3],x2             //src_tmp2 = vld1_u8(pu1_src_tmp)//
    smlal       v30.4s, v17.4h, v28.4h
    ld1         {v6.4h},[x3],x2             //src_tmp3 = vld1_u8(pu1_src_tmp)//
    smlal       v30.4s, v18.4h, v29.4h
    ld1         {v7.4h},[x3],x2             //src_tmp4 = vld1_u8(pu1_src_tmp)//

    st1         {v19.s}[0],[x1],#4          //vst1_u8(pu1_dst,sto_res)//
    sqshrn      v21.4h, v21.4s,#6
    sqrshrun    v20.8b, v20.8h,#6           //sto_res = vqmovun_s16(sto_res_tmp)//
    add         x20,x1,x9
    csel        x1, x20, x1,le

    subs        x7,x7,#4

    blt         epilog_end                  //jumps to epilog_end
    beq         epilog                      //jumps to epilog

kernel_8:

    smull       v19.4s, v1.4h, v23.4h       //mul_res1 = vmull_u8(src_tmp2, coeffabs_1)//
    subs        x4,x4,#4
    smlal       v19.4s, v0.4h, v22.4h       //mul_res1 = vmlal_u8(mul_res1, src_tmp1, coeffabs_0)//
    add         x20,x0,x8,lsl #0
    csel        x0, x20, x0,le
    smlal       v19.4s, v2.4h, v24.4h       //mul_res1 = vmlal_u8(mul_res1, src_tmp3, coeffabs_2)//
    smlal       v19.4s, v3.4h, v25.4h       //mul_res1 = vmlal_u8(mul_res1, src_tmp4, coeffabs_3)//
    smlal       v19.4s, v4.4h, v26.4h       //mul_res1 = vmlal_u8(mul_res1, src_tmp1, coeffabs_4)//
    smlal       v19.4s, v5.4h, v27.4h       //mul_res1 = vmlal_u8(mul_res1, src_tmp2, coeffabs_5)//
    smlal       v19.4s, v6.4h, v28.4h       //mul_res1 = vmlal_u8(mul_res1, src_tmp3, coeffabs_6)//
    smlal       v19.4s, v7.4h, v29.4h       //mul_res1 = vmlal_u8(mul_res1, src_tmp4, coeffabs_7)//
    st1         {v20.s}[0],[x14],x6         //vst1_u8(pu1_dst_tmp,sto_res)//

    sqshrn      v30.4h, v30.4s,#6
    sqrshrun    v21.8b, v21.8h,#6
    ld1         {v16.4h},[x3],x2            //src_tmp1 = vld1_u8(pu1_src_tmp)//

    smull       v20.4s, v2.4h, v23.4h       //mul_res2 = vmull_u8(src_tmp3, coeffabs_1)//
    smlal       v20.4s, v1.4h, v22.4h       //mul_res2 = vmlal_u8(mul_res2, src_tmp2, coeffabs_0)//
    smlal       v20.4s, v3.4h, v24.4h       //mul_res2 = vmlal_u8(mul_res2, src_tmp4, coeffabs_2)//
    smlal       v20.4s, v4.4h, v25.4h       //mul_res2 = vmlal_u8(mul_res2, src_tmp1, coeffabs_3)//
    smlal       v20.4s, v5.4h, v26.4h       //mul_res2 = vmlal_u8(mul_res2, src_tmp2, coeffabs_4)//
    smlal       v20.4s, v6.4h, v27.4h       //mul_res2 = vmlal_u8(mul_res2, src_tmp3, coeffabs_5)//
    st1         {v21.s}[0],[x14],x6

    smlal       v20.4s, v7.4h, v28.4h       //mul_res2 = vmlal_u8(mul_res2, src_tmp4, coeffabs_6)//
    ld1         {v17.4h},[x3],x2            //src_tmp2 = vld1_u8(pu1_src_tmp)//

    smlal       v20.4s, v16.4h, v29.4h      //mul_res2 = vmlal_u8(mul_res2, src_tmp1, coeffabs_7)//

    sqshrn      v19.4h, v19.4s,#6
    sqrshrun    v30.8b, v30.8h,#6

    smull       v21.4s, v3.4h, v23.4h
    csel        x4, x5, x4,le               //x5 ->wd

    smlal       v21.4s, v2.4h, v22.4h
    ld1         {v18.4h},[x3],x2            //src_tmp3 = vld1_u8(pu1_src_tmp)//

    smlal       v21.4s, v4.4h, v24.4h
    add         x3,x0,x2                    //pu1_src_tmp += src_strd//

    smlal       v21.4s, v5.4h, v25.4h

    smlal       v21.4s, v6.4h, v26.4h
    st1         {v30.s}[0],[x14],x6

    smlal       v21.4s, v7.4h, v27.4h
    ld1         {v1.4h},[x3],x2             //src_tmp2 = vld1_u8(pu1_src_tmp)//

    smlal       v21.4s, v16.4h, v28.4h
    add         x14,x1,x6

    smlal       v21.4s, v17.4h, v29.4h
    ld1         {v0.4h},[x0],#8             //src_tmp1 = vld1_u8(pu1_src_tmp)//

    sqshrn      v20.4h, v20.4s,#6
    sqrshrun    v19.8b, v19.8h,#6           //sto_res = vqmovun_s16(sto_res_tmp)//
    ld1         {v2.4h},[x3],x2             //src_tmp3 = vld1_u8(pu1_src_tmp)//

    smull       v30.4s, v4.4h, v23.4h
    smlal       v30.4s, v3.4h, v22.4h
    smlal       v30.4s, v5.4h, v24.4h
    ld1         {v3.4h},[x3],x2             //src_tmp4 = vld1_u8(pu1_src_tmp)//

    smlal       v30.4s, v6.4h, v25.4h
    ld1         {v4.4h},[x3],x2             //src_tmp1 = vld1_u8(pu1_src_tmp)//
    smlal       v30.4s, v7.4h, v26.4h
    ld1         {v5.4h},[x3],x2             //src_tmp2 = vld1_u8(pu1_src_tmp)//
    smlal       v30.4s, v16.4h, v27.4h
    ld1         {v6.4h},[x3],x2             //src_tmp3 = vld1_u8(pu1_src_tmp)//
    smlal       v30.4s, v17.4h, v28.4h
    ld1         {v7.4h},[x3],x2             //src_tmp4 = vld1_u8(pu1_src_tmp)//
    smlal       v30.4s, v18.4h, v29.4h
    st1         {v19.s}[0],[x1],#4          //vst1_u8(pu1_dst,sto_res)//

    sqshrn      v21.4h, v21.4s,#6
    add         x20,x1,x9
    csel        x1, x20, x1,le

    sqrshrun    v20.8b, v20.8h,#6           //sto_res = vqmovun_s16(sto_res_tmp)//
    subs        x7,x7,#4

    bgt         kernel_8                    //jumps to kernel_8

epilog:

    smull       v19.4s, v1.4h, v23.4h       //mul_res1 = vmull_u8(src_tmp2, coeffabs_1)//
    smlal       v19.4s, v0.4h, v22.4h       //mul_res1 = vmlal_u8(mul_res1, src_tmp1, coeffabs_0)//
    smlal       v19.4s, v2.4h, v24.4h       //mul_res1 = vmlal_u8(mul_res1, src_tmp3, coeffabs_2)//
    smlal       v19.4s, v3.4h, v25.4h       //mul_res1 = vmlal_u8(mul_res1, src_tmp4, coeffabs_3)//
    smlal       v19.4s, v4.4h, v26.4h       //mul_res1 = vmlal_u8(mul_res1, src_tmp1, coeffabs_4)//
    smlal       v19.4s, v5.4h, v27.4h       //mul_res1 = vmlal_u8(mul_res1, src_tmp2, coeffabs_5)//
    smlal       v19.4s, v6.4h, v28.4h       //mul_res1 = vmlal_u8(mul_res1, src_tmp3, coeffabs_6)//
    smlal       v19.4s, v7.4h, v29.4h       //mul_res1 = vmlal_u8(mul_res1, src_tmp4, coeffabs_7)//
    st1         {v20.s}[0],[x14],x6

    sqshrn      v30.4h, v30.4s,#6
    sqrshrun    v21.8b, v21.8h,#6

    ld1         {v16.4h},[x3],x2            //src_tmp1 = vld1_u8(pu1_src_tmp)//
    smull       v20.4s, v2.4h, v23.4h       //mul_res2 = vmull_u8(src_tmp3, coeffabs_1)//
    smlal       v20.4s, v1.4h, v22.4h       //mul_res2 = vmlal_u8(mul_res2, src_tmp2, coeffabs_0)//
    smlal       v20.4s, v3.4h, v24.4h       //mul_res2 = vmlal_u8(mul_res2, src_tmp4, coeffabs_2)//
    smlal       v20.4s, v4.4h, v25.4h       //mul_res2 = vmlal_u8(mul_res2, src_tmp1, coeffabs_3)//
    smlal       v20.4s, v5.4h, v26.4h       //mul_res2 = vmlal_u8(mul_res2, src_tmp2, coeffabs_4)//
    smlal       v20.4s, v6.4h, v27.4h       //mul_res2 = vmlal_u8(mul_res2, src_tmp3, coeffabs_5)//
    smlal       v20.4s, v7.4h, v28.4h       //mul_res2 = vmlal_u8(mul_res2, src_tmp4, coeffabs_6)//
    smlal       v20.4s, v16.4h, v29.4h      //mul_res2 = vmlal_u8(mul_res2, src_tmp1, coeffabs_7)//
    st1         {v21.s}[0],[x14],x6

    sqshrn      v19.4h, v19.4s,#6
    sqrshrun    v30.8b, v30.8h,#6

    ld1         {v17.4h},[x3],x2            //src_tmp2 = vld1_u8(pu1_src_tmp)//
    smull       v21.4s, v3.4h, v23.4h
    smlal       v21.4s, v2.4h, v22.4h
    smlal       v21.4s, v4.4h, v24.4h
    smlal       v21.4s, v5.4h, v25.4h
    smlal       v21.4s, v6.4h, v26.4h
    smlal       v21.4s, v7.4h, v27.4h
    smlal       v21.4s, v16.4h, v28.4h
    smlal       v21.4s, v17.4h, v29.4h
    st1         {v30.s}[0],[x14],x6
    sqshrn      v20.4h, v20.4s,#6
    sqrshrun    v19.8b, v19.8h,#6           //sto_res = vqmovun_s16(sto_res_tmp)//

    ld1         {v18.4h},[x3],x2            //src_tmp3 = vld1_u8(pu1_src_tmp)//
    smull       v30.4s, v4.4h, v23.4h
    smlal       v30.4s, v3.4h, v22.4h
    smlal       v30.4s, v5.4h, v24.4h
    smlal       v30.4s, v6.4h, v25.4h
    smlal       v30.4s, v7.4h, v26.4h
    smlal       v30.4s, v16.4h, v27.4h
    smlal       v30.4s, v17.4h, v28.4h
    smlal       v30.4s, v18.4h, v29.4h
    sqshrn      v21.4h, v21.4s,#6
    sqrshrun    v20.8b, v20.8h,#6           //sto_res = vqmovun_s16(sto_res_tmp)//

    add         x14,x1,x6
    st1         {v19.s}[0],[x1],#4          //vst1_u8(pu1_dst,sto_res)//

epilog_end:
    st1         {v20.s}[0],[x14],x6         //vst1_u8(pu1_dst_tmp,sto_res)//
    sqrshrun    v21.8b, v21.8h,#6

    st1         {v21.s}[0],[x14],x6
    sqshrn      v30.4h, v30.4s,#6
    sqrshrun    v30.8b, v30.8h,#6

    st1         {v30.s}[0],[x14],x6


end_loops:

    // ldmfd sp!,{x4-x12,x15}                  //reload the registers from sp
    ldp         x19, x20,[sp], #16

    ret




















