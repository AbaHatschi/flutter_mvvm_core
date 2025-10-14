import 'package:flutter/material.dart';

import 'base_view_model.dart';

/// Generic View with binding to a ViewModel
class BaseView<T extends BaseViewModel> extends StatefulWidget {
  const BaseView({super.key, required this.viewModel, required this.builder});

  final T viewModel;
  final Widget Function(BuildContext context, T vm, Widget? child) builder;

  @override
  State<BaseView<T>> createState() => _BaseViewState<T>();
}

class _BaseViewState<T extends BaseViewModel> extends State<BaseView<T>> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (BuildContext context, Widget? child) =>
          widget.builder(context, widget.viewModel, child),
    );
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }
}
