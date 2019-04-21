// Copyright (c) 2018 ml5
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

/* ===
ml5 Example
Image Classification using Feature Extraction with MobileNet. Built with p5.js
This example uses a callback pattern to create the classifier
=== */

let featureExtractor;
let classifier;
let video;
let loss;
let dogImages = 0;
let catImages = 0;

var drumloop = new Audio('loop.mp3');

function setup() {
  noCanvas();
  // Create a video element
  video = createCapture(VIDEO);
  // Append it to the videoContainer DOM element
  video.parent('videoContainer');
  // Extract the already learned features from MobileNet
  featureExtractor = ml5.featureExtractor('MobileNet', modelReady);
  // Create a new classifier using those features and give the video we want to use
  classifier = featureExtractor.classification(video, videoReady);
  // Set up the UI buttons
  setupButtons();
  classifier.load("model/model.weights.bin")
  classifier.load("model/model.json", function(){
    select('#modelStatus').html('Custom Model Loaded!');
  });
}

// A function to be called when the model has been loaded
function modelReady() {
  select('#modelStatus').html('Base Model (MobileNet) Loaded!');
  classifier.load('./model/model.json', function() {
    select('#modelStatus').html('Custom Model Loaded!');
    classify()
  });
}

// A function to be called when the video has loaded
function videoReady () {
  select('#videoStatus').html('Video ready!');
}

// Classify the current frame.
function classify() {
  classifier.classify(gotResults);
}

// A util function to create UI buttons
function setupButtons() {

  // Predict Button
  buttonPredict = select('#buttonPredict');
  buttonPredict.mousePressed();

}

// Show the results
function gotResults(err, result) {
  // Display any error
  if (err) {
    console.error(err);
  }

  if (result === "dog") {
    //do something
    $("body").css("background-color", "red")
    if (isPlaying(drumloop) === false) {
      drumloop.play()
    }
  }

  if (result === "cat") {
    //do something else
    $("body").css("background-color", "aquamarine")
    drumloop.pause();
    drumloop.currentTime = 0;
  }

  select('#result').html(result);
  classify();
}

function isPlaying(audelem) { return !audelem.paused; }
