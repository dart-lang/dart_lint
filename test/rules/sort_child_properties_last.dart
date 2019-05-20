// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N sort_child_properties_last`

// ignore_for_file: prefer_expression_function_bodies

class W0 extends Widget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Center(), // OK
      ),
    );
  }
}

class W1 extends Widget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Center(), // LINT
        key: 0,
      ),
    );
  }
}

class W2 extends Widget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        key: 0,
        child: Center(), // OK
      ),
    );
  }
}

class W3 extends Widget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        key: 0,
        child: Center(
          child: Column(
            key: 0,
            children: [], // OK
          ),
        ),
      ),
    );
  }
}

class W4 extends Widget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        key: 0,
        child: Center(
          child: Column(
            children: [], // LINT
            key: 0,
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

class BuildContext {}

abstract class Widget {
  const Widget();
  Widget build(BuildContext context) => null;
}

class Scaffold extends Widget {
  const Scaffold({
    int key,
    Widget body,
    // ...
  });
}

class Center extends Widget {
  const Center(
      {int key, double widthFactor, double heightFactor, Widget child});
}

class Column extends Widget {
  Column({
    int key,
    List<Widget> children = const <Widget>[],
  });
}

