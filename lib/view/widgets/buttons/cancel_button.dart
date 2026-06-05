import 'package:flutter/material.dart';

class CancelButton extends StatelessWidget {
  final VoidCallback? onTap;

  const CancelButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () => Navigator.of(context).maybePop(),
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
                height: 1.10,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
