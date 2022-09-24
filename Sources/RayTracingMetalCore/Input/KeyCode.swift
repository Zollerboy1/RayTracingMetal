//
//  KeyCode.swift
//  RayTracingMetalCore
//
//  Created by Josef Zoller on 28.08.22.
//

extension Input {
    public enum KeyCode: Int32 {
         case space = 32
         case apostrophe = 39 /* ' */
         case comma = 44 /* , */
         case minus = 45 /* - */
         case period = 46 /* . */
         case slash = 47 /* / */

         case _0 = 48 /* 0 */
         case _1 = 49 /* 1 */
         case _2 = 50 /* 2 */
         case _3 = 51 /* 3 */
         case _4 = 52 /* 4 */
         case _5 = 53 /* 5 */
         case _6 = 54 /* 6 */
         case _7 = 55 /* 7 */
         case _8 = 56 /* 8 */
         case _9 = 57 /* 9 */

         case semicolon = 59 /* ; */
         case equal = 61 /* = */

         case a = 65
         case b = 66
         case c = 67
         case d = 68
         case e = 69
         case f = 70
         case g = 71
         case h = 72
         case i = 73
         case j = 74
         case k = 75
         case l = 76
         case m = 77
         case n = 78
         case o = 79
         case p = 80
         case q = 81
         case r = 82
         case s = 83
         case t = 84
         case u = 85
         case v = 86
         case w = 87
         case x = 88
         case y = 89
         case z = 90

         case leftBracket = 91  /* [ */
         case backslash = 92  /* \ */
         case rightBracket = 93  /* ] */
         case graveAccent = 96  /* ` */

         case world1 = 161 /* non-US #1 */
         case world2 = 162 /* non-US #2 */

         /* Function keys */
         case escape = 256
         case enter = 257
         case tab = 258
         case backspace = 259
         case insert = 260
         case delete = 261
         case right = 262
         case left = 263
         case down = 264
         case up = 265
         case pageUp = 266
         case pageDown = 267
         case home = 268
         case end = 269
         case capsLock = 280
         case scrollLock = 281
         case numLock = 282
         case printScreen = 283
         case pause = 284
         case f1 = 290
         case f2 = 291
         case f3 = 292
         case f4 = 293
         case f5 = 294
         case f6 = 295
         case f7 = 296
         case f8 = 297
         case f9 = 298
         case f10 = 299
         case f11 = 300
         case f12 = 301
         case f13 = 302
         case f14 = 303
         case f15 = 304
         case f16 = 305
         case f17 = 306
         case f18 = 307
         case f19 = 308
         case f20 = 309
         case f21 = 310
         case f22 = 311
         case f23 = 312
         case f24 = 313
         case f25 = 314

         /* Keypad */
         case keypad0 = 320
         case keypad1 = 321
         case keypad2 = 322
         case keypad3 = 323
         case keypad4 = 324
         case keypad5 = 325
         case keypad6 = 326
         case keypad7 = 327
         case keypad8 = 328
         case keypad9 = 329
         case keypadDecimal = 330
         case keypadDivide = 331
         case keypadMultiply = 332
         case keypadSubtract = 333
         case keypadAdd = 334
         case keypadEnter = 335
         case keypadEqual = 336

         case leftShift = 340
         case leftControl = 341
         case leftAlt = 342
         case leftSuper = 343
         case rightShift = 344
         case rightControl = 345
         case rightAlt = 346
         case rightSuper = 347
         case menu = 348
    }
}
