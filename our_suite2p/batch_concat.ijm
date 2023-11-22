inputDir = getDirectory("");

processDir(inputDir);

//inputDir (directory) is a collection of Folders.

function processDir(inputDir) {
	listdir = getFileList(inputDir);
	for (j = 0; j < listdir.length; j++) {
		print("Processing: " + listdir[j]);
		directory = inputDir + listdir[j];
		setBatchMode(true);
		processFolder(directory);
		setBatchMode(false);
	}
}

//processFolder function manipulates a stack of images in a folder.

function processFolder(directory) {
	fileList = getFileList(directory);
	n = 0; //Record number of tifs
	ch1 = 0; //Record number of Channel 1 files
	ch2 = 0; //Record number of Channel 2 files
	for (i=0; i < fileList.length; i++) {
		if (matches(fileList[i],".*tif.*")) {
			n=n+1;
		
			if (matches(fileList[i],".*Ch1.*")) {
				ch1=ch1+1;
			}
			else {
				if (matches(fileList[i],".*Ch2.*")) {
					ch2=ch2+1;
				}
			}
		}
	}

	if (n>10) {
		//Run for Ch1...
		if (ch1>1) { //If there are Channel 1 files, execute this code
			run("Image Sequence...", "open=&directory file=Ch1 sort");
			imageName = getTitle();
			imageName = imageName + "-Ch1.tif";
			path = directory+imageName;
			save(path);
			print("Saved " + path);
					
			while (nImages>0) { 
				selectImage(nImages); 
				close(); 
			}
		}
		else {
		print("No Channel 1 files.");
		}
		
		//Run for Ch2...
		if (ch2>1) { //If there are Channel 2 files, execute this code 
			run("Image Sequence...", "open=&directory file=Ch2 sort");
			imageName = getTitle();
			imageName = imageName + "-Ch2.tif";
			path = directory+imageName;
			save(path);
			print("Saved " + path);
					
			while (nImages>0) { 
				selectImage(nImages); 
				close(); 
			}
		}
		else {
		print("No Channel 2 files.");
		}
			
		// Delete tif files
		for (i=0; i < fileList.length; i++)
		if (matches(fileList[i],".*tif.*")) {
			print("Deleting " + directory + fileList[i]);
			deleting = File.delete(directory + fileList[i]);
		}
	}
	 else {
		print("Not enough images to cocatenate in " + directory);
	}



}


