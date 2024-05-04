<br />
<p align="center">
  <h1 align="center">Stock Market Simulation</h1>

  <p align="center">
A trading and educational app designed for beginners by a team of students at Florida Southern College. It offers an online course, news updates, mock trading, and statistical views.  </p>
</p>

## Table of Contents

* [About the Project](#about-the-project)
  * [Built With](#built-with)
* [Getting Started](#getting-started)
  * [Prerequisites](#prerequisites)
  * [Installation](#installation)
  * [Running](#running)
* [Modules](#modules)
* [Notes](#notes)
* [Evaluation](#evaluation)
* [Extras](#extras)

## About The Project

TradeWise is a beginner-friendly stock market trading app focused on enhancing learning and experience for all users. Each user creates an account securely stored on a Firebase database, allowing for continuous tracking of their trades and course progress.     

The app features multiple sections, including a learning module where users can follow a foundational stock trading course to grasp essential techniques. These skills can be practiced in the trading section, where users buy and sell stocks in real-time using virtual money provided by the app.     

Users receive daily news updates on relevant stocks and can access updated charts with day, month, or year timeframes. Additionally, the app offers a comprehensive analytics tool that calculates total profit, unrealized profit, and other key metrics in the portfolio and analytics section.     

## Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites

* [Python 3.10.0](https://www.python.org/downloads/) or higher
* [Flutter for Android 3.19.6](https://docs.flutter.dev/get-started/install) or higher
* [Android Studio](https://developer.android.com/studio/install#windows) with Pixel 7 Pro 11.0("R")|x86 API 30 model for best experience
* [Uvicorn 0.29.0](https://www.uvicorn.org) or higher

### Installation

1.Navigate to the API code in the TradeWise API folder and run:    
  "python -m uvicorn main:app --port 5000 --reload"    
  or    
  "uvicorn main:app --port 5000 --reload"    
2.Create an Android emultor in Android Studio with these specifications for the best experience:    
  "Pixel 7 Pro 11.0("R")|x86 API 30"    

### Running

1.Activate the Android emultor as your device on the down right section     
2.Navigate to the "main" file in the TradeWise App folder and run these 3 lines of code:    
  "flutter clean"    
  "dart pub get"   
  "flutter run"    
  
## Modules

**Course Page:**

Our course provides a comprehensive, fundamental stock trading curriculum sourced from the internet, which is then broken down into concise, digestible modules to facilitate learning. Student progress is saved locally and on our Firebase database, displayed through a progress bar at the top of the page. After completing the course, students can add a few thousand virtual dollars to their accounts and start experimenting with real-world stocks.

**Saved Page:**

The Saved (or Favorited) Page is the first page users see upon logging in. Initially blank, users can search for their favorite stocks and add them to their list. Each saved stock is displayed as a card, showing its current market price and stock code. The prices are retrieved through our custom API, which integrates data from Yahoo Finance's old stock API. This API provides current market prices, closing prices for the last month or year, and daily news updates on relevant stocks.

Each stock card contains three buttons: one that displays detailed charts on daily, monthly, and yearly timeframes, one that opens a trading section for that specific stock, and one that removes the stock from the saved list.

**Trading Page:**

Clicking the "wallet" icon on a stock's card takes users to a page where they can trade that specific stock. The page shows the current stock price and the user's balance. If users don't have any funds to trade, they can add $5,000 in virtual money or input a dollar amount to invest in that stock. Once they hit "trade," the transaction is recorded in the online database, ready for other features to access.

**Trades Page:**

All transactions placed by the user are saved to the Firebase database and retrieved for display on the Trades Page. Open trades are shown first, followed by closed trades. Each card displays the stock code, the amount owned, and the current profit for open trades or closed profit for completed trades. The profit for open trades is calculated based on the purchase price and current market price from our API. Open trades include a red button that closes them, while the top of the page displays the user's current balance and total unrealized profit calculated from all open trades.

**News Section:**

The News Section retrieves relevant stock news from our custom API and presents them in individual cards. Users can read the headlines or dive deeper into the articles. A built-in browser within the app allows users to read the full articles directly.

**Settings Page:**

The Settings Page is simple, featuring an option for users to upload a profile picture from their library, which is also saved to the database. It includes a basic notification system designed to alert users when the market opens and closes, though this feature isn't fully implemented yet. The page also provides a button that opens the user's portfolio.

**Portfolio Page:**

The Portfolio Page gives a detailed analytical overview of a user's trading performance, featuring a pie chart with their owned stocks and their proportions. It includes metrics such as total profit since trading began and unrealized profit, calculated as explained earlier. The best- and worst-performing stocks are highlighted based on their growth percentage since acquisition. The lower part of the page includes an unfinished feature that would visualize unrealized profit growth over time. This feature requires a costly, always-on API that wasn't acquired.

Users can also search for others in the database to view their profiles. This feature was designed to help students learn from each other and follow more experienced traders' strategies. For experimental purposes, two profiles, "Brenda" and "Vlad," can be found.

## Design

<!--
List all the design patterns you used in your program. For every pattern, describe the following:
- Where it is used in your application.
- What benefit it provides in your application. Try to be specific here. For example, don't just mention a pattern improves maintainability, but explain in what way it does so.
-->

## Evaluation

<!--
Discuss the stability of your implementation. What works well? Are there any bugs? Is everything tested properly? Are there still features that have not been implemented? Also, if you had the time, what improvements would you make to your implementation? Are there things which you would have done completely differently? Try to aim for at least 250 words.
-->

## Extras

<!--
If you implemented any extras, you can list/mention them here.
-->

___


<!-- Below you can find some sections that you would normally put in a README, but we decided to leave out (either because it is not very relevant, or because it is covered by one of the added sections) -->

<!-- ## Usage -->
<!-- Use this space to show useful examples of how a project can be used. Additional screenshots, code examples and demos work well in this space. You may also link to more resources. -->

<!-- ## Roadmap -->
<!-- Use this space to show your plans for future additions -->

<!-- ## Contributing -->
<!-- You can use this section to indicate how people can contribute to the project -->

<!-- ## License -->
<!-- You can add here whether the project is distributed under any license -->


<!-- ## Contact -->
<!-- If you want to provide some contact details, this is the place to do it -->

<!-- ## Acknowledgements  -->
