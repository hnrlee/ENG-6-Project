v = VideoReader('sampleVideo.mp4');
while hasFrame(v)
    video = readFrame(v);
    image(video);
    drawnow;
end