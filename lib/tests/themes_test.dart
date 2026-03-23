//TESTED IN MAIN
//COPY PASTE FROM RUN APP TILL THE END TO SEE THE TEST AND STYLES

// runApp(
//         MaterialApp(
//       theme: AppTheme.dark,
//       home: ThemeTestScreen(), // test the themes 
//     ),
//   );
// }


// class ThemeTestScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) { // ← context exists here
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('displayLarge', style: Theme.of(context).textTheme.displayLarge),
//             Text('titleLarge', style: Theme.of(context).textTheme.titleLarge),
//             Text('bodyMedium', style: Theme.of(context).textTheme.bodyMedium),
//             ElevatedButton(onPressed: () {}, child: Text('Primary Button')),
//             SizedBox(height: 16),
//             Container(height: 50, color: AppColors.primary),
//             Container(height: 50, color: AppColors.danger),
//             Container(height: 50, color: AppColors.card),
//           ],
//         ),
//       ),
//     );
//   }
// }