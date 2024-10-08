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
* [Design](#design)
* [Evaluation](#evaluation)
* [Extras](#acknowledgements)

## Project Demo   
Please follow the link below for a project demonstration.    

Link: https://www.loom.com/share/500d9381ad374fa0a2823acb47b0289c?sid=4405c764-4c69-4f81-b0f7-6e4ff1fbb45b 

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

Start the TradeWise API:

1. Navigate to the API code located in the TradeWise API folder.   
   Open the terminal and make sure you're in the TradeWise API folder.   
   Run one of the following commands to start the API server:   
    "python -m uvicorn main:app --port 5000 --reload"       
    or      
    "uvicorn main:app --port 5000 --reload"      
  
3. Set up an Android Emulator in Android Studio:   
    Create a new Android emulator using the following specifications for the best experience:    
    Device: Pixel 7 Pro    
    Android Version: 11.0 ("R")    
    CPU/ABI: x86    
    API Level: 30      

### Running

1. Activate the Android Emulator:    
      Go to the bottom-right section of VS Code.    
      Click on the current device selection (it may say "Windows" or another option).    
      Select your Android emulator from the list to set it as your device and run it.    
    
2. Run the TradeWise App:    
      Navigate to the lib/main.dart file located in the TradeWise App folder.    
      Open the terminal and make sure you're in the lib folder.    
   Run the following commands in sequence:       
      "flutter clean"      
      "cd .."    
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

The Model, View, Service (MVS) design pattern is used throughout the development of this app. This structure provides a well-defined organization that enhances maintainability, modularity, and scalability. Here's how each section is structured and the benefits they offer:

1. **Modules Section (Model):**
   - The Modules section prioritizes different stock models, creating clear data structures that developers can easily understand and modify.
   - It provides a consistent data framework for storing, retrieving, and manipulating data.
   - Benefits include:
     - Simplified feature implementation since data relationships and structures are predefined.
     - Clear data separation, reducing errors and improving data integrity.
     - Centralized data logic, making debugging and updates more straightforward.

2. **Pages Section (View):**
   - In mobile apps, the "View" is represented by various pages (screens) that form the user interface.
   - Each page in this app corresponds to a specific function, like trading, news, and portfolio.
   - Benefits include:
     - A user-friendly interface that guides users through the app's features intuitively.
     - Isolated UI components that streamline updates and allow independent customization.
     - Enhanced user engagement through interactive layouts, data visualizations, and real-time information.

3. **Service Section (Service):**
   - The Service section handles background functions such as database management and API communication.
   - This layer manages data synchronization with Firebase and interacts with the custom API.
   - Benefits include:
     - Robust backend logic that streamlines data management, ensuring consistent and accurate information across pages.
     - Centralized APIs to interact seamlessly with external services, enhancing security and reducing network traffic.

**Custom API:**
- The custom API was created using Uvicorn, a lightning-fast ASGI server for Python.
- It provides tailored information on current stock prices and historical data.
- Benefits include:
  - Customization allows the API to deliver data specific to the app’s requirements, minimizing irrelevant information.
  - Real-time data fetching ensures accurate stock information and updates.
  - Enables advanced data analysis and visualization through structured and optimized endpoints.

**Firebase:**
- Firebase serves as the core database and authentication platform for the app, providing several key benefits:
  - Real-Time Synchronization: Synchronizes data across user devices in real time, ensuring that changes and updates are consistently reflected.
  - Secure Data Storage: Stores data securely with robust encryption and user authentication to protect sensitive information.
  - User Authentication: Simplifies account management by allowing users to register and sign in with email/password or third-party providers. This ensures only authenticated users can access sensitive features.
  - Simplified Implementation: Reduces development time for managing user accounts, file storage, and analytics by integrating these services seamlessly. This results in faster implementation and a more cohesive data management strategy.

## Evaluation

The app's overall functionality is robust. Authentication operates seamlessly, enabling users to register and sign in without issues while securely saving their information in Firebase. The app comprehensively covers the features expected in a virtual trading platform, and the custom API provides real-time data to give users an immersive experience. However, one area that could be improved is the speed of extracting and managing user data from the database. In future iterations, finding a more efficient way to access data will be crucial for delivering a smoother user experience. For instance, launching data-intensive pages like the portfolio page, which requires significant database extraction, API retrievals, and complex calculations, can result in slight delays that impact user satisfaction.

Two other features weren't completed during development: the notification system and real-time updates of unrealized profit. The notification system would have required more time and effort to implement functions like notifying users when a specific trade has reached a particular growth percentage or alerting them when the market opens and closes. Although preliminary tests were conducted, the desired functionality was not fully achieved. Meanwhile, real-time unrealized profit updates require fundamental changes to the API structure. This feature would need a constantly running API hosted on a dedicated server, along with a scheduled process to access the database at specific times. The process would calculate unrealized profit daily and save the results back to the database for later visualization in the portfolio analytics.

These two features represent a strong starting point for the app's future development. With more time and resources, their implementation would significantly enhance the overall trading experience, providing users with a more comprehensive and solid platform.

## Acknowledgements

This app was developed as part of a group project within the Florida Southern College Computer Science department. I would like to acknowledge the other team members who also contributed to this successful project:
 - Brenda Alvarez
 - Cade Butler
 - Joshua Hammond

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
