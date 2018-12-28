const http = require('http');

const hostname = '127.0.0.1';
const port = 3000;

const server = http.createServer((req, res) => {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');
    res.end('Hello World\n');
});

server.listen(port, hostname, () => {
    console.log(`Server running at http://${hostname}:${port}/`);
});

var config = require('./config.js');

const eventListener = config.gameContract.events(event => {
    console.group('New event received');
    console.log('- Contract Address:', event.contract);
    console.log('- Event Name:', event.name);
    console.log('- Transaction:', event.transaction);
    console.log('- Block number:', event.block);
    console.log('- Result:', event.result, '\n');
    console.groupEnd();
}).start(err => {
    if (err)
        return console.error('Failed to start event listener:', err);
    console.log('Event listener started\n');
});
//
// config.gameContract.BetLog().watch((err, event) => {
//     if (err)
//         return console.error('Error with "Message" event:', err);
//     console.group('New event received');
//     console.log('- Contract Address:', event.contract);
//     console.log('- Event Name:', event.name);
//     console.log('- Transaction:', event.transaction);
//     console.log('- Block number:', event.block);
//     console.log('- Result:', event.result, '\n');
//     console.groupEnd();
// });