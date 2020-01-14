#!/usr/bin/env ruby

IMAGES_DIR = "images"
DOCKER_HUB_USER = ENV['DOCKER_USERNAME']

def process_file(file)
  printf "[*] process file [%s]\n", file
  File.open(IMAGES_DIR + "/" + file, "r") do |f|
    f.each_line do |line|
      process_line file, line.strip
    end
  end
end

def process_line(host, line)
  if line.length > 0
    install_images host, line
  end
end

def install_images(prefix, image)
  local_image = DOCKER_HUB_USER + "/" + image
  printf "[*] pulling cached image [%s]\n", local_image
  pulled = system "docker", "pull", local_image
  if pulled
    printf "[*] local image already exists, skipped\n"
    return
  end
  remote_image = prefix + "/" + image
  printf "[*] pulling remote image [%s]\n", remote_image
  pulled = system "docker", "pull", remote_image
  unless pulled
    printf "[*] remote image [%s] not found, skipped\n", remote_image
    return
  end
  printf "[*] tag remote image [%s] to cached image [%s]\n", remote_image, local_image
  system "docker", "tag", remote_image, local_image
  printf "[*] pushing [%s] to docker hub\n"
  system "docker", "push", local_image
end

Dir.foreach(IMAGES_DIR) do |file|
  if file !="." and file !=".."
    process_file file
  end
end

