import 'package:flutter/material.dart';
import 'animated_text.dart';
import 'ring.dart';

class AnimatedButton extends StatefulWidget {
  AnimatedButton({
    Key key,
    @required this.text,
    @required this.onPressed,
    @required this.controller,
    this.loadingColor,
    this.color,
  }) : super(key: key);

  final String text;
  final Color color;
  final Color loadingColor;
  final Function onPressed;
  final AnimationController controller;

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  Animation<double> _sizeAnimation;
  Animation<double> _textOpacityAnimation;
  Animation<double> _buttonOpacityAnimation;
  Animation<double> _ringThicknessAnimation;
  Animation<double> _ringOpacityAnimation;
  Animation<Color> _colorAnimation;
  var _isLoading = false;
  var _hover = false;

  Color _color;
  Color _loadingColor;

  static const _width = 120.0;
  static const _height = 40.0;
  static const _loadingCircleRadius = _height / 2;
  static const _loadingCircleThickness = 4.0;

  @override
  void initState() {
    super.initState();

    _textOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: Interval(0.0, .25),
      ),
    );

    _sizeAnimation = Tween<double>(begin: 1.0, end: _height / _width)
        .animate(CurvedAnimation(
      parent: widget.controller,
      curve: Interval(0.0, .65, curve: Curves.fastOutSlowIn),
    ));

    // _colorAnimation

    _buttonOpacityAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: widget.controller,
      curve: Threshold(.65),
    ));

    _ringThicknessAnimation =
        Tween<double>(begin: _loadingCircleRadius, end: _loadingCircleThickness)
            .animate(CurvedAnimation(
      parent: widget.controller,
      curve: Interval(.65, .85),
    ));
    _ringOpacityAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: widget.controller,
      curve: Interval(.85, 1.0),
    ));

    widget.controller.addStatusListener(handleStatusChanged);
  }

  @override
  void didChangeDependencies() {
    _updateColorAnimation();
    super.didChangeDependencies();
  }

  void _updateColorAnimation() {
    final theme = Theme.of(context);
    final buttonTheme = theme.floatingActionButtonTheme;

    _color = widget.color ?? buttonTheme.backgroundColor;
    _loadingColor = widget.loadingColor ?? theme.accentColor;

    _colorAnimation = ColorTween(
      begin: _color,
      end: _loadingColor,
    ).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.0, .65, curve: Curves.fastOutSlowIn),
      ),
    );
  }

  @override
  void didUpdateWidget(AnimatedButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.color != widget.color ||
        oldWidget.loadingColor != widget.loadingColor) {
      _updateColorAnimation();
    }
  }

  @override
  void dispose() {
    widget.controller.removeStatusListener(handleStatusChanged);
    super.dispose();
  }

  void handleStatusChanged(status) {
    if (status == AnimationStatus.forward) {
      setState(() => _isLoading = true);
    }
    if (status == AnimationStatus.dismissed) {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildButtonText(ThemeData theme) {
    return FadeTransition(
      opacity: _textOpacityAnimation,
      child: AnimatedText(
        text: widget.text,
        style: theme.textTheme.button,
      ),
    );
  }

  Widget _buildButton(ThemeData theme) {
    final buttonTheme = theme.floatingActionButtonTheme;

    return FadeTransition(
      opacity: _buttonOpacityAnimation,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        child: AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child) => Material(
            shape: buttonTheme.shape,
            color: _colorAnimation.value,
            child: child,
            shadowColor: _color,
            elevation: !_isLoading
                ? (_hover
                    ? buttonTheme.highlightElevation
                    : buttonTheme.elevation)
                : 0,
          ),
          child: InkWell(
            onTap: !_isLoading ? widget.onPressed : null,
            splashColor: buttonTheme.splashColor,
            customBorder: buttonTheme.shape,
            onHighlightChanged: (value) => setState(() => _hover = value),
            child: SizeTransition(
              sizeFactor: _sizeAnimation,
              axis: Axis.horizontal,
              child: Container(
                width: _width,
                height: _height,
                alignment: Alignment.center,
                child: _buildButtonText(theme),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        FadeTransition(
          opacity: _ringOpacityAnimation,
          child: AnimatedBuilder(
            animation: _ringThicknessAnimation,
            builder: (context, child) => Ring(
              color: widget.loadingColor,
              size: _height,
              thickness: _ringThicknessAnimation.value,
            ),
          ),
        ),
        if (_isLoading)
          SizedBox(
            width: _height - _loadingCircleThickness,
            height: _height - _loadingCircleThickness,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(widget.loadingColor),
              // backgroundColor: Colors.red,
              strokeWidth: _loadingCircleThickness,
            ),
          ),
        _buildButton(theme),
      ],
    );
  }
}
