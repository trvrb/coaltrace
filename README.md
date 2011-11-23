=========
coaltrace
=========

This is a simulation of the basic demographic / genealogical process. Individuals are born and 
individuals die. This causes lineages to branch and to disappear, and causes the population to share 
a common ancestor at some time in the past. The coalescent provides a mathematical description of 
these patterns of ancestry.

Individuals are represented as circles. Layout is taken care of through simple physics. Each 
individual is given a charge and Coulomb's law is used to for repulsion. The edges of the screen are 
also charged.

Individuals leave a trace of where they used to be. I was pleasantly surprised to have the physical 
location of a lineage cleanly reveal its genealogical history.

----------------------------

This is written entirely in Processing.  It will compile via the processing IDE into a Java 
application, and it will launch from a browser using the Processing.js Javascript library.