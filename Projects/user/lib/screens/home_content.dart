import 'package:flutter/material.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Color(0xFFA3C1AD),
          ),
        ),
      Row(
        children: [
          Column(
            
            children: [
              Card(
                child: Column(
                  children: [
                    Image.asset('assets/snow.jpeg',width: 200,height: 180,),
                    Text('womens cloths')
                  ],
                ),
              ),
              Card(
                child: Column(
                  children: [
                    Image.asset('assets/pc.jpg',width: 200,height: 180,),
                    Text('womens cloths')
                  ],
                ),
              )
            ],
          )
        ],
      )
      ],
    );
  }
}
