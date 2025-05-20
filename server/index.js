const express = require('express');
const http = require('http');
const socketIO = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = socketIO(server, {
  cors: {
    origin: '*',
  },
});

io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  // Handle user joining a room
  socket.on('join', (roomId) => {
  console.log(`User ${socket.id} joined room: ${roomId}`);
  socket.join(roomId);
  socket.to(roomId).emit('user-joined', socket.id);
});

  // Handle offer
  socket.on('offer', (data) => {
  console.log(`Offer from ${socket.id} to room ${data.roomId}`);
  socket.to(data.roomId).emit('offer', data);
});

socket.on('answer', (data) => {
  console.log(`Answer from ${socket.id} to room ${data.roomId}`);
  socket.to(data.roomId).emit('answer', data);
});


socket.on('ice-candidate', (data) => {
  console.log(`ICE candidate from ${socket.id} to room ${data.roomId}`);
  socket.to(data.roomId).emit('ice-candidate', data);
});

  // Handle user disconnect
  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Signaling server is running on port ${PORT}`);
});
