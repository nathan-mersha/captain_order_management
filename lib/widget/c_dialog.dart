import 'package:flutter/material.dart';

class CDialog extends StatefulWidget {
  final String message;
  final Function onYes;
  final Function onNo;
  final double font;
  final TextAlign textAlign;

  final Widget widgetYes;
  final Widget widgetNo;

  CDialog({this.message, this.onYes, this.onNo, this.font, this.textAlign, this.widgetYes, this.widgetNo});

  @override
  State<StatefulWidget> createState() {
    return _CDialogState();
  }
}

class _CDialogState extends State<CDialog> {
  final String _tickImgPath = "assets/images/operation/tick.png";
  final String _crossImgPath = "assets/images/operation/cross.png";
  final double _iconHeight = 32;
  final double _textFontSize = 21;
  final EdgeInsets _containerMargin = EdgeInsets.symmetric(horizontal: 300);
  final EdgeInsets _containerPadding = EdgeInsets.symmetric(horizontal: 17, vertical: 24);
  final double _spacing1 = 40;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Card(
            margin: _containerMargin,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            color: Colors.white,
            child: Center(
              child: Container(
                margin: _containerPadding,
                child: Column(
                  children: <Widget>[
                    Text(
                      widget.message,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: widget.font == null ? _textFontSize : widget.font,
                      ),
                      textAlign: widget.textAlign == null ? TextAlign.center : widget.textAlign,
                      maxLines: 5,
                    ),
                    SizedBox(
                      height: _spacing1,
                    ),
                    widget.onNo == null
                        ? Container(
                      width: double.infinity,
                      child: FlatButton(
                        child: Image.asset(
                          _tickImgPath,
                          height: _iconHeight,
                        ),
                        onPressed: widget.onYes,
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: FlatButton(
                            child: widget.widgetYes != null
                                ? widget.widgetYes
                                : Image.asset(
                              _tickImgPath,
                              height: _iconHeight,
                            ),
                            onPressed: widget.onYes,
                          ),
                        ),
                        Container(
                          height: 60,
                          width: 3,
                          color: Colors.black26
                        ),
                        Expanded(
                          child: FlatButton(
                            child: widget.widgetNo != null
                                ? widget.widgetNo
                                : Image.asset(
                              _crossImgPath,
                              height: _iconHeight,
                            ),
                            onPressed: widget.onNo,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
