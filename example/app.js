// This is a test harness for your module
// You should do something interesting in this harness 
// to test out the module and to provide instructions 
// to users on how to use it by example.

var customPhotoAlbumModule = require('ti.customphotoalbum');

var image = Ti.UI.createImageView({
	image: '/images/mike1.jpg',
	width: 320,
	top: 0
});
				
var blob = image.getImage();

customPhotoAlbumModule.addCustomAlbumAndSaveImage(blob, "MyCustomAlbum！");