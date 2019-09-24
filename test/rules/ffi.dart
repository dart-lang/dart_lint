// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N ffi`

import 'dart:ffi';

// No FFI types except Struct may be extended.
class X extends Void  {}  //LINT
class X extends Int8  {}  //LINT
class X extends Uint8  {}  //LINT
class X extends Int16  {}  //LINT
class X extends Uint16  {}  //LINT
class X extends Int32  {}  //LINT
class X extends Uint32  {}  //LINT
class X extends Int64  {}  //LINT
class X extends Uint64  {}  //LINT
class X extends Float  {}  //LINT
class X extends Double  {}  //LINT
class X extends Pointer {}  //LINT
class X extends Struct<X> {}  //OK

// No FFI types may be implemented.
class X implements Void  {}  //LINT
class X implements Int8  {}  //LINT
class X implements Uint8  {}  //LINT
class X implements Int16  {}  //LINT
class X implements Uint16  {}  //LINT
class X implements Int32  {}  //LINT
class X implements Uint32  {}  //LINT
class X implements Int64  {}  //LINT
class X implements Uint64  {}  //LINT
class X implements Float  {}  //LINT
class X implements Double  {}  //LINT
class X implements Pointer {}  //LINT
class X implements Struct<X> {}  //LINT

// Structs may not be generic.
class X<T> extends Struct<X<T>> {}  //LINT
