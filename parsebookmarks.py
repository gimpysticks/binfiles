from xml.dom.minidom import parse
import xml.dom.minidom

# Open XML document using minidom parser
DOMTree = xml.dom.minidom.parse("/home/sticks/Desktop/Bookmark")
collection = DOMTree.documentElement
if collection.hasAttribute("roots"):
   print (collection.getAttribute("roots"))

