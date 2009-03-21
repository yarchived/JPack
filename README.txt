JPack is a small addon which can easily resort your items in your bags and bank. (Designed in China.)
Autor: Jason Green,yleaf

___/Feature\___

1. FAST, it's very FAST!
2. Stack up automatically and smart. If you have 3 bandages in your bank and 12 in bag, addon will stack the bandages from bag to bank.
3. Easy and powerful. The sorting order is changable.
4. It has a minimap icon and supports Data broker (you'll need a LDB-based display addon)
(Though it's databroker supported now, but I still hope it will be enhanced by inventory mods. There are many modifierd(click to pack) inventory addons in china.)
(You can delete <plugins> folder if you don't want this.)


___/Usage\___

CMD: /jpack OR /jp

/jp - Pack
/jp minimap OR mm - Toggle minimap icon
/jp asc - Set sequence to asc
/jp desc - Set sequence to desc
/jp deposit OR save - Save to the bank
/jp draw OR load - Load from the bank
/jp debug - Show debug info, to check pack or item category info
/jp nodebug - Close debug info


___/Order\___

No GUI config interface but you can handle it through changing lua-code.

Example(You can get more by opening files in <JPack\localization>):

JPACK_ORDER={"Hearthstone","##Mounts","Mining Pick","Skinning Knife","Fishing Pole","#Fishing Poles",
"#Weapon","#Armor","#Weapon##Other","#Armor##Other","#Recipe",
"#Quest","##Elemental","##Metal & Stone","##Herb","#Gem","##Jewelcrafting",
"#Consumable","##Cloth","#Trade Goods","##Meat","#","Fish Oil","Soul Shard","#Miscellaneous"}
JPACK_DEPOSIT={"##Elemental","##Metal & Stone","##Herb","#Jewelcrafting","#Container"}
JPACK_DRAW={"#Quest"}

Instruction:
#XX			type of a item
##XX		subtype
#X##Y		X(type) AND Y(subtype)
#			single "#", items before "#" will be put in front of those writen after "#"

Hearthstone			An item called [Hearthstone]
#Weapon				Type matches "Weapon", easy to understand
##Mount				Subtype matchs Mounts, usually mounts;)
#Armor##Other		Type is Armor and subtype is Other

To get the type you can get some small addons such as yGravier or Engravings(both could be found at wowinterface.com).

**you can create your own order by modifying <JPackConfig.lua>. It will be loaded after locale files so you can always use your own order.


___/Other\___

WEB:			http://wow-jpack.googlecode.com/
Changelog:		http://code.google.com/p/wow-jpack/wiki/ChangeList

Bug reports, feature requests and locale files submit: http://code.google.com/p/wow-jpack/issues/entry
