#!/bin/bash
## Copyright (c) 2012 by Doom5 <doom5@inbox.com>
##
## Permission is hereby granted, free of charge, to any person
## obtaining a copy of this software and associated documentation
## files (the "Software"), to deal in the Software without
## restriction, including without limitation the rights to use,
## copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the
## Software is furnished to do so, subject to the following
## conditions:
##
## The above copyright notice and this permission notice shall be
## included in all copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
## EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
## OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
## NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
## HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
## WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
## FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
## OTHER DEALINGS IN THE SOFTWARE.


# Link all'immagine
LINK=http://www.eurowebcamsite.com/webcams/webcam-campobasso/webcam_termoli.jpg
# Tempo di aggiornamento in secondi
REFRESH=600
# Directory di lavoro
WORKDIR=$HOME/.sfondosfondato
# File immagine temporaneo
FTEMP=$WORKDIR/.sfondosfondatotmp.jpg
# File immagine definitivo da impostare come sfondo
FILEOUT=$WORKDIR/sfondosfondato.jpg

## Editor immagine
# Attiva l'editor dell'immagine se vale true
EDITAON=true
# Risoluzione proprio schermo per adattamento immagine
RESMONITORO=1280
RESMONITORV=800
# Striscie di pixel ritagliate ai quattro lati dell'immagine
PSU=130
PGIU=130
PDESTRA=0
PSINISTRA=0


# Edita immagine
edit()
{
	# Prende dimenzione in pixel orizzontale e verticale
	RESIMO=$(identify -format "%w" $FTEMP)
	RESIMV=$(identify -format "%h" $FTEMP)
 
	# Controlla che le porzioni da ritagliare non siano più grandi dell'immagine
	if expr $(($PSU+$PGIU)) \< $RESIMV \& $(($PDESTRA+$PSINISTRA)) \< $RESIMO > /dev/null
	then	
		# Sceglie di quanto scalare garantendo la massima risoluzione apprezzabile		
		if  expr $(($RESIMO*1000/$RESMONITORO)) \> $(($RESIMV*1000/$RESMONITORV)) > /dev/null
		then	
			# Ritaglia e fissa la dimenzione verticale
			convert -crop $(($RESIMO-$PDESTRA-$PSINISTRA))"x"$(($RESIMV-$PGIU-$PSU))"+"$PSINISTRA"+"$PSU -resize "x"$(($RESMONITORV+10)) $FTEMP $FTEMP
		else
			# Ritaglia e fissa la dimenzione orizzontale
			convert -crop $(($RESIMO-$PDESTRA-$PSINISTRA))"x"$(($RESIMV-$PGIU-$PSU))"+"$PSINISTRA"+"$PSU -resize $(($RESMONITORO+10))"x" $FTEMP $FTEMP
		fi
	else
		# Stampa errore su shell, ma nessuno lo leggerà, ma in ogni caso la vita continua...
		echo "Strisce da ritagliare più grandi dell'immagine, fai attenzione!"
	fi	
}


# Esegue una sola volta per uso con cron
cron()
{
	if ! test -d $WORKDIR 
	then
		mkdir $WORKDIR
	fi
	wget -qO $FTEMP $LINK
	if expr $? \=\= 0 >> /dev/null
	then
		if $EDITAON
		then
			edit
			cp $FTEMP $FILEOUT
		else
			cp $FTEMP $FILEOUT
		fi
	fi
}


# Esegue infinite volte ad intevalli di tempo
nocron()
{
	while true
	do
		cron
		sleep $REFRESH
	done
}


case "$1" in
	cron)
		cron
	;;
	nocron)
		nocron
	;;
	*)
		echo "Lo script creerà la directory di lavoro in "$WORKDIR". L'ideale sarebbe mettere anche lo script li!"
		echo "Devi passare un parametro:"
		echo "\n cron \t-se vuoi eseguire una sola volta lo script, ideale per l'uso con cron."
		echo "\n nocron \t-se vuoi eseguire infinite volte lo script ad intervalli di "$REFRESH" sec."
		echo "Per tutte le opzioni ed opinioni devi editare le variabili dello scripto"
	;;
esac

