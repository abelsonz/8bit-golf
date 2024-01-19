// Define the Particle class
class Particle {
  PVector pos, vel, acc; // Position, velocity, and acceleration vectors
  float size, hue; // Size of the particle and its hue (unused in this code)
  boolean stuckInSandtrap = false; // New variable to track if the particle is stuck in the sandtrap

  // Constructor for the Particle class
  Particle(PVector startPosition) {
    pos = startPosition.copy(); // Set the initial position of the particle
    float speed = 0; // Initial speed is set to 0
    vel = PVector.random2D().mult(speed); // Create a random 2D vector for velocity
    size = 25; // Set the size of the particle
    acc = new PVector(0, 0); // Initialize acceleration to zero
  }

  // Apply forces from attractors and repellers to the particle
  void applyForces(ArrayList<PVector> attractors, ArrayList<PVector> repellers) {
    acc.set(0, 0); // Reset acceleration to zero

    // Calculate attraction forces from each attractor
    for (PVector attractor : attractors) {
      PVector attraction = PVector.sub(attractor, pos); // Vector pointing from particle to attractor
      float dist = attraction.mag(); // Calculate distance to attractor
      dist = max(dist, 10); // Prevent division by very small numbers
      attraction.normalize(); // Normalize to get direction
      attraction.mult(1 / sq(dist)); // Calculate force magnitude inversely proportional to distance squared
      acc.add(attraction); // Add this force to the particle's acceleration
    }

    // Calculate repulsion forces from each repeller
    for (PVector repeller : repellers) {
      PVector repulsion = PVector.sub(pos, repeller); // Vector pointing from repeller to particle
      float dist = repulsion.mag(); // Calculate distance to repeller
      dist = max(dist, 10); // Prevent division by very small numbers
      repulsion.normalize(); // Normalize to get direction
      repulsion.mult(500 / sq(dist)); // Calculate force magnitude inversely proportional to distance squared
      acc.add(repulsion); // Add this force to the particle's acceleration
    }
  }

  // Check if the particle has made contact with the sandtrap
  void stickToSandtrap() {
    stuckInSandtrap = true;
    pos.set(sandtrap.x, sandtrap.y); // Move the particle to the center of the sandtrap
    vel.set(0, 0); // Stop the particle's movement
    acc.set(0, 0); // Reset acceleration
  }

  // Update the particle's position based on its velocity and acceleration
  void move() {
    if (!stuckInSandtrap) {
      pos.add(vel); // Update position based on velocity

      // Reflect the particle off the edges of the window
      if (pos.x <= 0 || pos.x >= width) {
        vel.x *= -1; // Reverse x velocity
        pos.x = constrain(pos.x, 0, width); // Keep position within bounds
      }
      if (pos.y <= 0 || pos.y >= height) {
        vel.y *= -1; // Reverse y velocity
        pos.y = constrain(pos.y, 0, height); // Keep position within bounds
      }
      vel.add(acc); // Update velocity based on acceleration
  }
  }

  // Display the particle on the canvas
  void display() {
    noStroke(); // Do not draw a stroke around shapes
    fill(255); // Set color to white
    circle(pos.x, pos.y, size); // Draw the main circle for the particle

    // Draw dimples on the particle for visual effect
    float dimpleSize = size / 5; // Size of each dimple
    int dimples = 6; // Number of dimples
    for (int i = 0; i < dimples; i++) {
      float angle = TWO_PI / dimples * i; // Calculate angle for each dimple
      float dimpleX = pos.x + cos(angle) * size / 3; // X coordinate of dimple
      float dimpleY = pos.y + sin(angle) * size / 3; // Y coordinate of dimple
      fill(200); // Set color for dimples
      circle(dimpleX, dimpleY, dimpleSize); // Draw each dimple
    }
  }

  // Check if the particle has made contact with an attractor
  boolean checkContact(PVector attractor) {
    float distance = PVector.dist(pos, attractor); // Calculate distance to attractor
    return distance < 15; // Return true if within a certain distance threshold
  }
}
