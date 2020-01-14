#!/usr/bin/env ruby

IMAGES_DIR = "images"
DOCKER_HUB_USER = ENV['DOCKER_USERNAME']

def process_file(file)
  puts "[*] process file [%s]" % file
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
  puts "[*] pulling cached image [%s]" % local_image
  pulled = system "docker", "pull", local_image
  #if pulled
  #  puts "[*] local image already exists, skipped"
  #  return
  #end
  remote_image = prefix + "/" + image
  puts "[*] pulling remote image [%s]" % remote_image
  pulled = system "docker", "pull", remote_image
  unless pulled
    puts "[*] remote image [%s] not found, skipped" % remote_image
    return
  end
  puts "[*] tag remote image [%s] to cached image [%s]" % [remote_image, local_image]
  system "docker", "commit", "-m='%s'" % "mirror of " + remote_image, remote_image, local_image
  puts "[*] pushing [%s] to docker hub" % local_image
  system "docker", "push", local_image
end

Dir.foreach(IMAGES_DIR) do |file|
  if file !="." and file !=".."
    process_file file
  end
end

