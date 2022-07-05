import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';

class CharacterCardData {
  const CharacterCardData({
    required this.characterName,
    required this.status,
    required this.spice,
    required this.lastKnownLocation,
    required this.firstEpisodeName,
    required this.imageURL,
  });

  final String characterName;
  final String status;
  final String spice;
  final String lastKnownLocation;
  final String firstEpisodeName;
  final String imageURL;
}

class CharacterCard extends StatelessWidget {
  final CharacterCardData cardData;
  final double? width;
  final double? height;
  final double? radius;
  final BorderRadius _cardBorderRadius;
  final BorderRadius _imageBorderRadius;
  final bool _isHorizontal;

  CharacterCard.vertical(
      {super.key, required this.cardData, this.width, this.height, this.radius})
      : _isHorizontal = false,
        _imageBorderRadius = radius == null
            ? BorderRadius.zero
            : BorderRadius.only(
                topLeft: Radius.circular(radius),
                topRight: Radius.circular(radius)),
        _cardBorderRadius = radius == null
            ? BorderRadius.zero
            : BorderRadius.all(Radius.circular(radius));

  CharacterCard.horizontal(
      {super.key, required this.cardData, this.width, this.height, this.radius})
      : _isHorizontal = true,
        _imageBorderRadius = radius == null
            ? BorderRadius.zero
            : BorderRadius.only(
                topLeft: Radius.circular(radius),
                bottomLeft: Radius.circular(radius)),
        _cardBorderRadius = radius == null
            ? BorderRadius.zero
            : BorderRadius.all(Radius.circular(radius));

  @override
  Widget build(BuildContext context) {
    final Widget content;
    if (_isHorizontal) {
      content = Row(
        children: [
          _image(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: _body(context),
            ),
          ),
        ],
      );
    } else {
      content = Column(
        children: [
          Expanded(
            flex: 4,
            child: SizedBox(
              width: double.infinity,
              child: _image(),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: _body(context),
            ),
          )
        ],
      );
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: _cardBorderRadius),
      //TODO
      color: const Color.fromARGB(255, 60, 62, 68),
      child: SizedBox(height: height, width: width, child: content),
    );
  }

  ClipRRect _image() {
    return ClipRRect(
      borderRadius: _imageBorderRadius,
      child: Image.network(
        cardData.imageURL,
        fit: BoxFit.fill,
      ),
    );
  }

  Column _body(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Text(
          cardData.characterName,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        _statusLine(context),
        const Spacer(),
        _infoSection(
          context,
          title: "Last known location:",
          body: cardData.lastKnownLocation,
        ),
        const Spacer(),
        _infoSection(
          context,
          title: "First seen in:",
          body: cardData.firstEpisodeName,
        ),
        const Spacer()
      ],
    );
  }

  Widget _infoSection(BuildContext context,
      {required String title, required String body}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          body,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Row _statusLine(BuildContext context) {
    final Color iconColor;
    if (cardData.status == "Alive") {
      iconColor = Colors.green;
    } else if (cardData.status == "Dead") {
      iconColor = Colors.red;
    } else if (cardData.status == "unknown") {
      iconColor = Colors.grey[400]!;
    } else {
      throw "unexpected error no such status: '$cardData.status'";
    }

    return Row(
      children: [
        Icon(
          Icons.circle,
          color: iconColor,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            "${cardData.status.capitalize()} - ${cardData.spice}",
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        )
      ],
    );
  }
}
