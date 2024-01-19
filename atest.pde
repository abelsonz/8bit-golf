// Import the Processing sound library and declare global variables
import processing.sound.*;
SoundFile file;

PVector sandtrap;
boolean roundOver = false;

// Lists for storing particles, attractors, and repellers
ArrayList<Particle> particles = new ArrayList<Particle>();
ArrayList<PVector> attractors = new ArrayList<PVector>();
ArrayList<PVector> repellers = new ArrayList<PVector>();

int score = 0; // Variable to keep track of the score
PFont myFont; // Variable for the custom font

// The setup function runs once at the start of the sketch
void setup() {
  size(1000, 1000); // Set the size of the window
  background(0, 128, 0); // Set the background color
  myFont = createFont("pixelfont.ttf", 32); // Load the pixel font
  textFont(myFont); // Set the font to be used

  // Load and loop background music
  file = new SoundFile(this, "background_music.mp3");
  file.loop();

  initializeRound(); // Initialize the first round
}

// This function sets up a new round
void initializeRound() {
  // Clear existing attractors, repellers, and particles
  attractors.clear();
  repellers.clear();
  particles.clear();

  // Randomly place an attractor, avoiding too close to center
  float buffer = width / 4;
  float attractorX = random(buffer, width - buffer);
  float attractorY = random(buffer, height - buffer);
  attractors.add(new PVector(attractorX, attractorY));

  // Adjust buffer size for the repeller to ensure it stays within the canvas
  float repellerBuffer = 150; // Adjust as needed to accommodate red square

  // Additional buffer to ensure repeller is not too close to the attractor
  float additionalBuffer = 200; // Adjust as needed
  PVector repellerPos;
  boolean isTooClose;

  // Find a position for the repeller that is not too close to the attractor
  do {
    isTooClose = false;
    float repellerX = random(repellerBuffer, width - repellerBuffer);
    float repellerY = random(repellerBuffer, height - repellerBuffer);
    repellerPos = new PVector(repellerX, repellerY);

    // Check if the repeller is too close to the attractor
    for (PVector attractor : attractors) {
      if (PVector.dist(repellerPos, attractor) < additionalBuffer) {
        isTooClose = true;
        break;
      }
    }
  } while (isTooClose);

  // Add the repeller position to the list
  repellers.add(repellerPos);
  
 // Initialize the roundOver flag to false
  roundOver = false;
  
  // Initialize the sandtrap position, ensuring it doesn't overlap with attractors or repellers
  do {
    sandtrap = new PVector(random(width), random(height));
  } while (isTooCloseToAttractorsOrRepellers(sandtrap) || isInsideRedSquare(sandtrap));
}

// Function to check if a point is too close to any attractor or repeller
boolean isTooCloseToAttractorsOrRepellers(PVector point) {
  float minDistance = 50; // Minimum distance from attractors and repellers
  for (PVector attractor : attractors) {
    if (PVector.dist(point, attractor) < minDistance) return true;
  }
  for (PVector repeller : repellers) {
    if (PVector.dist(point, repeller) < minDistance) return true;
  }
  return false;
}  

// Function to check if a point is inside the red square around the repeller
boolean isInsideRedSquare(PVector point) {
    if (repellers.size() > 0) {
        PVector repeller = repellers.get(0);
        float squareSize = 100; // Same size as used in keyPressed method
        return point.x > repeller.x - squareSize && point.x < repeller.x + squareSize 
            && point.y > repeller.y - squareSize && point.y < repeller.y + squareSize;
    }
    return false;
}


// The draw function continuously loops to animate the sketch
void draw() {
    background(0, 128, 0); // Redraw the background
    displaySandtrap(); // Display the sandtrap
    displayAttractorsAndRepellers();

    if (!roundOver) {
        updateParticles();
    } else {
        displayEndRoundMessage();
    }

    displayScore();
    displayInstructions();
}

void updateParticles() {
    ArrayList<Particle> particlesToRemove = new ArrayList<Particle>();

    for (Particle p : particles) {
        p.applyForces(attractors, repellers);
        p.move();
        p.display();

        for (PVector attractor : attractors) {
            if (p.checkContact(attractor) && !particlesToRemove.contains(p)) {
                particlesToRemove.add(p);
                score++;
            }
        }

        if (p.checkContact(sandtrap)) {
            roundOver = true;
            p.stickToSandtrap();
        }
    }

    removeContactedParticles(particlesToRemove);
}

void displayEndRoundMessage() {
    textAlign(CENTER, CENTER);
    fill(255, 0, 0);
    textSize(32);
    text("You hit the sandtrap! Press the space bar to begin a new round", width / 2, height / 2);
    textAlign(LEFT);
}

void removeContactedParticles(ArrayList<Particle> particlesToRemove) {
    for (Particle p : particlesToRemove) {
        particles.remove(p);
    }
    if (!particlesToRemove.isEmpty()) {
        attractors.clear();
        repellers.clear();
        particles.clear();
        initializeRound();
    }
}


// Function to display the sandtrap
void displaySandtrap() {
  fill(194, 178, 128); // Sand color
  ellipse(sandtrap.x, sandtrap.y, 50, 50); // Draw the sandtrap as a circle
}



void displayAttractorsAndRepellers() {
  // Attractors: Golf Holes
  for (PVector attractor : attractors) {
    fill(0); // Black color for the hole
    ellipse(attractor.x, attractor.y, 20, 20); // Circle representing the hole

    // Flag on the Hole
    stroke(255, 0, 0); // Red color for the flag
    line(attractor.x, attractor.y, attractor.x, attractor.y - 30); // Flagpole
    fill(255, 0, 0); // Red flag
    triangle(attractor.x, attractor.y - 30, attractor.x, attractor.y - 20, attractor.x + 10, attractor.y - 25); // Flag triangle
  }

  noStroke();

  // Repellers: Golf Club Representation with Black Outline
  for (PVector repeller : repellers) {
    // Club Head
    stroke(0); // Black outline
    fill(128); // Dark gray color for club head
    rect(repeller.x - 10, repeller.y, 20, 10); // Small rectangle for club head

    // Club Shaft
    line(repeller.x, repeller.y, repeller.x, repeller.y - 50); // Line for club shaft
  }
  noStroke(); // Reset stroke for other drawings
  

  // Draw square around the repeller
   if (repellers.size() > 0) {
    PVector repeller = repellers.get(0);
    float squareSize = 100; // Same size as used in keyPressed method
    noFill(); // No fill for the square
    stroke(255, 0, 0); // Red outline for visibility
    rectMode(CENTER); // Draw rectangle from its center
    rect(repeller.x, repeller.y, squareSize * 2, squareSize * 2); // Draw the square
   }

  
}

// The keyPressed function is called whenever a key is pressed
void keyPressed() {
 if (roundOver && key == ' ') {
    initializeRound(); // Reinitialize the round
  } else if (!roundOver) {
  switch(key) {
    case 'p':
      // When 'p' is pressed, add a particle at the mouse location if it's within the bounds of the repeller
      PVector repeller = repellers.get(0); // Retrieve the first (and presumably only) repeller
      float squareSize = 100; // Define the interaction area around the repeller
      // Check if the mouse is within a square area around the repeller
      if (mouseX > repeller.x - squareSize && mouseX < repeller.x + squareSize 
          && mouseY > repeller.y - squareSize && mouseY < repeller.y + squareSize) {
        particles.add(new Particle(new PVector(mouseX, mouseY))); // Add a new particle at the mouse position
      }
      break;

    case 'a':
      // When 'a' is pressed, add an attractor at the current mouse position
      attractors.add(new PVector(mouseX, mouseY));
      break;

    case 'r':
      // When 'r' is pressed, add a repeller at the current mouse position
      repellers.add(new PVector(mouseX, mouseY));
      break;
}
  }
}


// The displayScore function displays the current score on the screen
void displayScore() {
  fill(255); // Set the fill color to white for the text
  textSize(20); // Set the size of the text
  text("Score: " + score, 10, 30); // Display the score text at coordinates (10, 30)
}


// Function to display instructions on the screen
void displayInstructions() {
  fill(255); // White color for the text
  textSize(20); // Size of the text
  text("Press P to place a particle inside the red square", 20, height - 30); // Position the text at the bottom left of the canvas
}
