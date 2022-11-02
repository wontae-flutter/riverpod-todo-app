import "package:flutter/material.dart";

class NavigatingScreen extends StatelessWidget {
  const NavigatingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Navigation buttons"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NavigatingButton(
              destination: "counter",
            ),
            NavigatingButton(
              destination: "todo",
            ),
          ],
        ),
      ),
    );
  }
}

class NavigatingButton extends StatelessWidget {
  final String destination;
  const NavigatingButton({
    super.key,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, "/${destination}");
      },
      child: Container(
        width: 80,
        height: 20,
        alignment: Alignment.center,
        child: Text(destination),
      ),
    );
  }
}
