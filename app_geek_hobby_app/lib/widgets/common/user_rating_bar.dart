import 'package:flutter/material.dart';

class UserRatingSlider extends StatefulWidget {
  final int initialRating;
  final ValueChanged<int> onChanged;

  const UserRatingSlider({
    super.key,
    required this.initialRating,
    required this.onChanged,
  });

  @override
  State<UserRatingSlider> createState() => _UserRatingSliderState();
}

class _UserRatingSliderState extends State<UserRatingSlider> {
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.initialRating.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Rating', style: TextStyle(fontSize: 16)),
        Slider(
          min: 0,
          max: 100,
          divisions: 100,
          value: _sliderValue,
          label: _sliderValue.round().toString(),
          onChanged: (value) {
            setState(() {
              _sliderValue = value;
            });
            widget.onChanged(_sliderValue.round());
          },
        ),
        Text(
          '${_sliderValue.round()} / 100',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}