-- Warning : Modifying this file without explicit knowledge of its content/structure may lead to SERIOUS ERRORS in your Titan Panel Menu.
-- Adding a New Skin to Titan Panel : 
-- 1) Make a new folder inside your "..\Interface\Addons\Titan\Artwork\Custom" folder. Let's call it "My Skin" for simplicity.
-- 2) Copy the necessary .tga graphic files inside that folder. Full path should be : "..\Interface\Addons\Titan\Artwork\Custom\My Skin"
-- 3) Add a line to the table below, providing a name that will appear as an option inside your Titan 'Skin Settings' submenu.
-- and add the above full path replacing '\' with double '\\'. In this example the line you should add will read as follows
-- { name = "My Custom Skin", path = "Interface\\AddOns\\Titan\\Artwork\\Custom\\My Skin\\"},
-- 4) Load WoW and activate the Titan right-click menu. You should be able to see the option to switch to your own skin.
-- Note : Adding new skin folders/files then modifying this file and forcing a ReloadUI WILL NOT make your skins visible.
-- World of Warcraft must be shut down entirely (if it's open) and then restarted for the new skins to take effect.
-- For questions/suggestions/additional help please visit : http://code.google.com/p/titanpanel/
-- Enjoy !
TITAN_CUSTOM_TEXTURES = {
{ name = "Default Skin", path = "Interface\\AddOns\\Titan\\Artwork\\"}, -- do not remove this line !
{ name = "Christmas", path = "Interface\\AddOns\\Titan\\Artwork\\Custom\\Christmas Skin\\"},
{ name = "Charcoal Metal", path = "Interface\\AddOns\\Titan\\Artwork\\Custom\\Charcoal Metal\\"},
{ name = "Crusader", path = "Interface\\AddOns\\Titan\\Artwork\\Custom\\Crusader Skin\\"},
{ name = "Cursed Orange", path = "Interface\\AddOns\\Titan\\Artwork\\Custom\\Cursed Orange Skin\\"},
{ name = "Dark Wood", path = "Interface\\AddOns\\Titan\\Artwork\\Custom\\Dark Wood Skin\\"},
{ name = "Deep Cave", path = "Interface\\AddOns\\Titan\\Artwork\\Custom\\Deep Cave Skin\\"},
{ name = "Elfwood", path = "Interface\\AddOns\\Titan\\Artwork\\Custom\\Elfwood Skin\\"},
{ name = "Engineer", path = "Interface\\AddOns\\Titan\\Artwork\\Custom\\Engineer Skin\\"},
{ name = "Frozen Metal", path = "Interface\\AddOns\\Titan\\Artwork\\Custom\\Frozen Metal Skin\\"},
{ name = "Graphic", path = "Interface\\AddOns\\Titan\\Artwork\\Custom\\Graphic Skin\\"},
{ name = "Graveyard", path = "Interface\\AddOns\\Titan\\Artwork\\Custom\\Graveyard Skin\\"},
{ name = "Hidden Leaf", path = "Interface\\AddOns\\Titan\\Artwork\\Custom\\Hidden Leaf Skin\\"},
{ name = "Holy Warrior", path = "Interface\\AddOns\\Titan\\Artwork\\Custom\\Holy Warrior Skin\\"},
{ name = "Nightlife", path = "Interface\\AddOns\\Titan\\Artwork\\Custom\\Nightlife Skin\\"},
{ name = "Orgrimmar", path = "Interface\\AddOns\\Titan\\Artwork\\Custom\\Orgrimmar Skin\\"},
{ name = "Plate", path = "Interface\\AddOns\\Titan\\Artwork\\Custom\\Plate Skin\\"},
{ name = "Tribal", path = "Interface\\AddOns\\Titan\\Artwork\\Custom\\Tribal Skin\\"},
{ name = "X-Perl", path = "Interface\\AddOns\\Titan\\Artwork\\Custom\\X-Perl\\"},
};