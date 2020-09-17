# VUE PWA ASSIGNMENT

### Customize configuration
See [Configuration Reference](https://cli.vuejs.org/config/).


### Setup up
## For Docker User
1) start docker compose
    ```
    docker-compose up -d
    ```
1) wait until installation finished for necessary node modules
1) access ```http://localhost:3000/``` for client
1) access ```http://127.0.0.1:5000/``` for Karate mock server
1) keep on learning to build vue project (You can surf more Karate mock APIs in `_mock_server_bulletinboard.feature`.)

## For Nomal User (Local Setup)
1) install `Java (8 or 8+)` for Karate mock server
1) install `nodejs` for vue
1) dive under project dir `<vue-pwa-frame>`
1) install node module
    ```
    yarn install
    ```
1) Compiles and hot-reloads for development
    ```
    yarn serve
    ```
1) Start Karate mock server
    ```
    java -jar karate-0.9.4.jar -m _mock_server_bulletinboard.feature -p 5000
    ```
1) access ```http://localhost:3080/``` for client
1) access ```http://127.0.0.1:5000/``` for Karate mock server
1) keep on learning to build vue project (You can surf more Karate mock APIs in `_mock_server_bulletinboard.feature`.)