const io = require('socket.io')(3000, {
  cors: {
    origin: '*',
  }
});

io.on('connection', socket => {
  console.log('Nuevo Usuario Conectado');

  socket.on('send_message', message => {
    console.log('Mensaje recibido:', message);
    
    socket.broadcast.emit('receive_message',  message);
  });
  
  socket.on('disconnect', () => {
    console.log('Usuario desconectado');
  });
});

console.log('Socket.io corriendo en el puerto 3000');