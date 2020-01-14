#!/usr/bin/env ruby

IMAGES_DIR = "images"
DOCKER_HUB_USER = "raylax"

def process_file(file)
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
  puts "[*] pulling image " + local_image
  pulled = system "docker", "pull", local_image
  if pulled
    puts "[*] "
  end
end

Dir.foreach(IMAGES_DIR) do |file|
  if file !="." and file !=".."
    process_file file
  end
end

