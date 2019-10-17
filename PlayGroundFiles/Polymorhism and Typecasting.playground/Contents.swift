import Cocoa


//  Because classes can inherit from each other (e.g. CountrySinger can inherit from Singer) it means one class is effectively a superset of another: class B has all the things A has, with a few extras. This in turn means that you can treat B as type B or as type A, depending on your needs.

//  Confused? Let's try some code:

class Album {
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    func getPerformance() -> String {
        return "The album \(name) sold lots"
    }

}

class StudioAlbum: Album {
    var studio: String
    
    init(name: String, studio: String) {
        self.studio = studio
        super.init(name: name)
    }
    
    override func getPerformance() -> String {
        return "The studio album \(name) sold lots"
    }
    
}

class LiveAlbum: Album {
    var location: String
    
    init(name: String, location: String) {
        self.location = location
        super.init(name: name)
    }
    
    override func getPerformance() -> String {
        return "The live album \(name) sold lots"
    }
}

//  That defines three classes: albums, studio albums and live albums, with the latter two both inheriting from Album. Because any instance of LiveAlbum is inherited from Album it can be treated just as either Album or LiveAlbum – it's both at the same time. This is called "polymorphism," but it means you can write code like this:

var taylorSwift = StudioAlbum(name: "Taylor Swift", studio: "The Castles Studios")
var fearless = StudioAlbum(name: "Speak Now", studio: "Aimeeland Studio")
var iTunesLive = LiveAlbum(name: "iTunes Live from SoHo", location: "New York")

//var allAlbums: [Album] = [taylorSwift, fearless, iTunesLive]
var allAlbums: [Album] = [taylorSwift, fearless]

//  There we create an array that holds only albums, but put inside it two studio albums and a live album. This is perfectly fine in Swift because they are all descended from the Album class, so they share the same basic behavior.

//  We can push this a step further to really demonstrate how polymorphism works. Let's add a getPerformance() method to all three classes:

for album in allAlbums {
    print(album.getPerformance())
}
//  That will automatically use the override version of getPerformance() depending on the subclass in question. That's polymorphism in action: an object can work as its class and its parent classes, all at the same time.


for album in allAlbums {
    let studioAlbum = album as! StudioAlbum
    print(studioAlbum.studio)
}


for album in allAlbums as! [StudioAlbum] {
    print(album.studio)
}

for album in allAlbums as? [LiveAlbum] ?? [LiveAlbum]() {
    print(album.location)
}


let number = 5
let text = String(number)
print(text)
