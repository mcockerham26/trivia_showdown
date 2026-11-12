
# Trivia Showdown
CSC 4360 - Mobile App Development
In-Class Activity 15
Maya Cockerham
November 11, 2026

## Project Overview

For this activity, I created a Flutter trivia app that gets questions from the Open Trivia Database API. The app loads five general knowledge questions and allows the user to select an answer for each one.

The app keeps track of the player's score, shows whether an answer is correct or incorrect, and displays the final score after all five questions are completed.

## Features

- Fetches five trivia questions using an HTTP GET request
- Converts JSON data into question objects
- Shuffles the multiple-choice answers
- Displays loading and error messages
- Highlights correct answers in green and incorrect answers in red
- Prevents users from answering the same question twice
- Tracks the player's score
- Allows the player to restart the game
- Simulates submitting the final score

## How to Run

1. Install Flutter and Dart.
2. Open the trivia_showdown project.
3. Run flutter pub get.
4. Start an Android emulator.
5. Run flutter run.

An internet connection is required to download new questions.

## API Implementation

The app uses the Open Trivia Database API to retrieve five easy multiple-choice general knowledge questions.

The HTTP status code is checked first to make sure the request succeeded. The app also checks the API response code before using the returned data.

The JSON response is converted into Dart objects so the questions and answers can be displayed.

The app uses asynchronous functions because retrieving information from the internet takes time. While waiting, the app displays a loading indicator. If the request fails, an error message and retry button appear.

## Score Submission

After the fifth question, the app displays the final score and provides an option to simulate score synchronization.

The simulation waits two seconds and displays a confirmation message. It does not actually upload the score to a cloud database.

A real leaderboard would require a backend endpoint that accepts and stores the submitted score.

## Critical Thinking Questions

### 1. What should happen if internet connectivity drops after the questions have loaded?

If the questions have already loaded, I think the player should still be able to finish the current round. The questions and answers are already stored in the app's memory, so the player should not need an internet connection to answer them.

The app should continue showing the current question and updating the score normally. If the player tries to restart and download new questions while offline, the app should display an error message and allow them to try again when the connection returns.

This would be better than immediately ending the game because the player has already downloaded the information needed to finish.

### 2. What data would be useful to save locally, and why would local storage not create a shared leaderboard?

I would save the player's previous scores locally. This would allow users to see how they performed in earlier rounds and compare their results over time.

Local storage would also allow the score history to remain available without an internet connection.

However, saving scores locally would not create a shared leaderboard because the information would only be stored on that user's device. Other players would not be able to access or compare those scores.

A shared leaderboard would require a backend database where scores from multiple users could be submitted and retrieved.

Local score history is only a proposed improvement and is not implemented in this version of the app.

## Testing

The app is designed to support the following tests:

- Load five questions from the API
- Display correct and incorrect answer feedback
- Prevent multiple answers to the same question
- Update the score correctly
- Display the final score
- Restart the trivia round
- Simulate score synchronization
- Display an error when the API request fails

Test evidence will be included with the assignment submission.

## Limitations

The score synchronization is simulated and does not save data to a real cloud database.

The app also does not currently save previous scores locally. A future version could add local score history and a shared leaderboard.

## GitHub Repository

https://github.com/mcockerham26/trivia_showdown
