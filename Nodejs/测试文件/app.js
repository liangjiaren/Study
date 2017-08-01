var net = require('net');

var client = new net.Socket();
client.setEncoding('utf8');

client.connect('3333', 'localhost', () => {
    console.log('connected');
    client.write('from client');
});

process.stdin.resume();

process.stdin.on('data', (data) => {
    console.log('write data ' + data);
    client.write(data);
})

client.on('data', (data) => {
    console.log('client data ' + data);
});

client.on('close', () => {
    console.log('close');
})