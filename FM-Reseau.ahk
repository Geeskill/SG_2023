#SingleInstance force

;D�termine le programme comme utilisation prioritaire du processeur
SetBatchLines, -1

#Include K:\CPIO\Equipe\Scripts\SEA\Crypt.ahk
#Include K:\CPIO\Equipe\Scripts\SEA\CryptConst.ahk
#Include K:\CPIO\Equipe\Scripts\SEA\CryptFoos.ahk

;Variable des fichiers
fichierconfig = I:\Config.ini
FichierReseaux = %A_ScriptDir%\Equipements-Reseaux.ini
Hotkey, LButton , On

;G�n�re les informations et options dans le Systray
Menu, Tray, Tip, Fait Marquant R�SEAUX
Menu, Tray, NoStandard
Menu, Tray, add, Relancer
Menu, Tray, Icon, Relancer, shell32.dll,239, 25
Menu, Tray, add,,
Menu, Tray, add, Quitter
Menu, Tray, Icon, Quitter, netshell.dll,98, 25

;V�rification de la version de FFSEC
VersionToUse = 1.38
IniRead, CheckFireFox, D:\Users\%A_Username%\Documents\Portable\FFSec\FirefoxPortable.ini, FirefoxPortable, FirefoxExecutable
RegExMatch(CheckFireFox,"(\d.+\d{2})", VersionFirefox) 
If VersionFirefox =
{
	MsgBox, 262160, Firefox non pr�sent, Firefox n'est pas install� sur votre machine.
	Run, http://ffsec/
	ExitApp
}
If VersionFirefox < 1.38
{
	MsgBox, 262160, Version de Firefox non compatible, Votre version de Firefox (%VersionFirefox%) n'est pas compatible avec l'outil FM-R�seau.`n`nIl vous faut au minimum la version %VersionToUse%.
	Run, http://ffsec/
	ExitApp	
}

;R�cup�ration des �quipements pour l'affichage dans la liste d�roulante
Loop, Read, %FichierReseaux%
{
	StringReplace, Tempo,A_LoopReadLine,[,, UseErrorLevel
	If Errorlevel
	{	
		StringReplace, Tempo,Tempo,],, All
		Equipements .=  Tempo "|"
	}
}
;Variable pour d�terminer si un routeur est un X ou Y
routy = _Y
routx = _X
Clipboard = ;Vidage du presse papier
OnMessage(0x200, "Informations") ;Fonction permettant d'afficher un message au passage de la souris sur un contr�le
WinGetPos,,,, TaskBar, ahk_class Shell_TrayWnd ;D�termine la hauteur de la taskbar
ecranprogress := (A_ScreenHeight - TaskBar - 160)
;Si la barre des taches est positionn� de mani�re vertical on d�fini une taille standard
If Taskbar = %A_ScreenHeight%
	ecranprogress := 760

HeureLancement := A_Hour ":" A_Min ;Variable permettant de connaitre l'heure � laquelle le programme a �t� lanc�

;################
;Cr�ation du GUI
;################
Gui,+AlwaysOnTop
Gui, Color, ffffff
Gui, Margin, 15, 15
;Gui, Add, Text, 0x6 xm y115 h220 w390,
;Gui, Add, Text, 0x6 xm y353 h230 w390,
;Gui, Add, Picture, x0 y0 w420 h642, %A_ScriptDir%\img\wall.png
Gui, Add, Picture, x300 y225 BackgroundTrans, %A_ScriptDir%\img\Reseau.png
Gui, Font, s14, Arial Black
Gui, Add, Text, xm+45 y10 w300 h25 vFM caf0000 Center, �QUIPEMENT IMPACT�
Gui, Font, s11 Bold, Arial Black
Gui, Add, Combobox, x60 y+10 w300 vChoixEquipement Uppercase gAc hwndHCBB Center, %Equipements%
Gui, Font, s10, Arial Black
Gui, Add, CheckBox, x60 y+5 vISO, Le site est isol� du r�seau
Gui, Add, GroupBox, section xm y+5 h230 w390 0x300 0x8000 c000000 BackgroundTrans,
Gui, Font, s12 Norm, Segoe UI Semibold
Gui, Add, Text,x25 ys+15 w350 vTP cad00cc BackgroundTrans , Type : /�
Gui, Add, Text,x25 y+10 w330 vRe BackgroundTrans, R�gion : /
Gui, Add, Text,x25 y+10 w370 vS1 BackgroundTrans, Site 1 : /
Gui, Add, Text,x25 y+2 w360 vS2 BackgroundTrans, Site 2 : /
Gui, Add, Text,x25 y+10 w290 vIP BackgroundTrans, Adresse IP : /
Gui, Add, Text,x25 y+10 w348 vSrv BackgroundTrans c0500cc, Service : /
;Gui, Add, Text, x45 y+10 w330 0x10
Gui, Font, s10 Norm, Segoe UI Semibold
Gui, Add, Button,x105 y+10 w200 vPing gPing Disabled, Ping de l'�quipement
;Gui, Add, Text, x45 y+3 w330 0x10
Gui, Add, GroupBox, section xm y+20 h270 w390 0x300 0x8000 c000000 BackgroundTrans,
Gui, Font, s14, Arial Black
Gui, Add, Text, x140 yp+10 BackgroundTrans, Date
Gui, Add, Text, x+90 yp w60 BackgroundTrans, Heure
Gui, Font, s14, Arial Black
Gui, Add, Edit, x70 yp+30 w50 Limit2 vChoixJour +Center caf0000 BackgroundTrans, %A_DD%
Gui, Add, Edit, x+1 yp w50 Limit2 vChoixMois +Center caf0000 BackgroundTrans, %A_MM%
Gui, Add, Edit, x+1 yp w80 Limit4 vChoixAnnee +Center caf0000 BackgroundTrans, %A_YYYY%
Gui, Add, Edit, x+20 yp w80 Limit5 vChoixHeure +Center caf0000 BackgroundTrans, %A_Hour%:%A_Min%
Gui, Font, s11, Arial Black
Gui, Add, Text, x150 y+10 vTextesfr BackgroundTrans, Ticket SFR
Gui, Add, Edit, x90 y+3 w200 Limit9 Uppercase vTicketSFR +Center c4d0069 BackgroundTrans,
Gui, Add, Picture, x+5 yp vLogoSFR gContactSFR, %A_ScriptDir%\img\SFR.png
Gui, Font, s10, Segoe UI Semibold
Gui, Add, CheckBox, x90 y+3 vSFR gSFR, Ticket SFR non g�n�r�
Gui, Font, s12, Arial Black
Gui, Add, Button,default x70 y+15 w280 vEnvoyer gRemplissage, OUVRIR LE FAIT MARQUANT
Gui, Font, s10, Segoe UI Semibold
Gui, Add, CheckBox,x70 y+5 vAckno Checked, Poser un Acknowledge
Gui, Add, CheckBox,x70 y+5 vSM, Service Manager est indisponible
Gui, Show, Autosize ,�Fait Marquant R�SEAUX

Ticket:
ClipWait ;Attente qu'un contenu arrive dans le presse-papier
GuiControlGet, SFR ;R�cup�ration de l'�tat de la checkbox SFR
If SFR = 0 ;Si la case n'est pas coch� on v�rifie le contenu du presse papier
{
	If RegExMatch(ClipBoard, "^((C)\d{8})$") ;On v�rifie que le num�ro de ticket SFR correspond
	{
		GuiControl,,TicketSFR,%Clipboard% ;On le place dans le champ Ticket SFR
		Hotkey, LButton , Off ;On d�sactive le syst�me de copie automatique
	}
	Else
		Goto, Ticket ;Si le REGEX ne correspond pas on retourne � l'action Ticket
}
Return


Informations()
{ ;Fonction permettant d'afficher un message au passage de la souris sur un contr�le
	If A_GuiControl = LogoSFR
		Message := "Cliquez ici pour contacter la hotline SFR"
	Else If A_GuiControl = Ping
		Message := "Cliquez ici pour effectuer un ping de l'�quipement"
	Else If A_GuiControl = ChoixHeure
		Message := "Indiquez ici l'heure de l'indisponibilit� de l'�quipement" 		
	Else If A_GuiControl = TicketSFR
		Message := "Saisissez ici le ticket SFR associ� au routeur"
    Else If A_GuiControl = SFR
		Message := "Cliquez ici pour ouvrir le FM dans le cas o� aucun ticket n'a �t� g�n�r� dans la BAL SFR.`nN'oubliez pas de g�n�rer un ticket en contactant la hotline SFR apr�s l'ouverture du FM."
	Else If A_GuiControl = Ackno
		Message := "Cette option permet de positionner un acknowledge automatique`nde l'�quipement apr�s la g�n�ration de la fiche Service Manager"	     
	Else If A_GuiControl = SM
		Message := "Cliquez ici lorsque Service Manager est indisponible.`nVous serez rediriger directement vers ERICA V2"	
    ToolTip % Message
}

;Script permettant de faire une copie automatique du ticket SFR pr�sent dans le mail.
~LButton::
	Loop
	{
		IfWinNotActive, ahk_class rctrl_renwnd32
			Return
		Sleep 10
		GetKeyState, LButtonState, LButton, P
		if LButtonState = U
			break
		{
			MouseGetPos x0, y0
			Loop
			{
				GetKeyState keystate, LButton
				IfEqual keystate, U,
				{
					MouseGetPos x, y
					break
				}
			}
			if (x-x0 > 30 or x-x0 < -30 or y-y0 > 30 or y-y0 < -30)
				Send, ^c
		  Return
		}
	}
Return

;Script d'auto-completion
AC:
	GuiControlGet, EditText, , %A_GuiControl%, Text
	If (EditText <> "") && ((EditText . "") <> (PrevText . "")) && (Item := CB_FindItem(HCBB, EditText, 0))
	{
		ItemText := CB_GetItemText(HCBB, Item)
		If (EditText . "") = (ItemText . "")
			CB_SelectItem(HCBB, Item)
		Else
		{
			GuiControl, Text, %A_GuiControl%, %ItemText%
			CB_SetEditSel(HCBB, StrLen(EditText) + 1, 0)
		}
	}
	PrevText := EditText

	Gui, submit, nohide ;R�cup�ration des valeurs du GUI
	;R�cup�re dans le fichier INI les infos et les stockent dans des variables.
	IniRead, infotype, %FichierReseaux%,%ChoixEquipement%,Type
	IniRead, inforegion, %FichierReseaux%,%ChoixEquipement%,Region
	IniRead, infosite1, %FichierReseaux%,%ChoixEquipement%,Site1
	IniRead, infosite2, %FichierReseaux%,%ChoixEquipement%,Site2
	IniRead, infoIP, %FichierReseaux%,%ChoixEquipement%,IP
	IniRead, infoservice, %FichierReseaux%,%ChoixEquipement%,Service

	;Si l'�quipement est un routeur nous activons les cases sp�cifiques (Ticket SFR, Site Isol�) autrement nous les d�sactivons.
	if infotype = Routeur
	{
		GuiControl, Enable, Iso	
		GuiControl, Enable, TicketSFR
		GuiControl, Enable, SFR
		GuiControl, Enable, SFR
		GuiControl, Enable, Textesfr
	}
	Else	
	{
		;Si le type d'�quipement n'existe pas on met un /
		If infotype = ERROR
			infotype = /
		GuiControl, Disable, Iso		
		GuiControl, Disable, TicketSFR
		GuiControl, Disable, SFR
		GuiControl, Disable, Textesfr
		GuiControl,,TexteSFR ,Ticket SFR
	}
	GuiControl,text,TP,Type : %infoType% ;Affichage
	if inforegion = ERROR
	{
		inforegion = /
		GuiControl,text,IP,Adresse IP : /
		GuiControl, Disable, Ping
	}
	Else
	{
		GuiControl,text,IP,Adresse IP : %infoip%
		GuiControl, Enable, Ping
	}
	if infosite1 = ERROR
		infosite1 = /
	if infosite2 = ERROR
		infosite2 = /
	if infoservice = ERROR
	InfoService = /
	GuiControl,text,re,R�gion : %inforegion%
	GuiControl,text,s1,Site 1 : %infosite1%
	GuiControl,text,s2,Site 2 : %infosite2%
	GuiControl,text,Srv,Service : %infoservice%
Return

Sfr:
	GuiControlGet, SFR
	If SFR = 0 
	{ 
		If RegExMatch(tempSFR, ".")
			GuiControl,,TicketSFR,%tempSFR%
		Else
			GuiControl,,TicketSFR,
		GuiControl, Enable, TicketSFR
	}
	Else     
	{
		GuiControlGet, tempsfr, ,TicketSFR
		GuiControl,,TicketSFR,EN COURS
		GuiControl, Disable, TicketSFR
	}
Return

Remplissage:
	Gui, Submit, NoHide
	If ChoixEquipement =
	{
		MsgBox,262160, �quipement manquant, Merci d'indiquer l'�quipement impact�.
		GuiControl, Focus, ChoixEquipement
		Return
	}

	If InfoRegion = /
	{
		MsgBox,262160, Equipement non r�f�renc� , L'�quipement saisi n'existe pas dans la base de donn�es Centreon.
		GuiControl, Focus, InfoRegion
		Return
	}

	If Not RegExMatch(ChoixJour, "^(0[1-9]|[12][0-9]|3[01])$")
	{
		MsgBox,262160,Format du jour incorrect, N'oubliez pas de rajouter un "0" si vous �tes dans la tranche du 1 au 9.`n`nExemple : 08 au lieu de 8
		GuiControl, Focus, ChoixJour
		Return
	}

	If Not RegExMatch(ChoixMois, "^(0[1-9]|1[012])$")
	{
		MsgBox,262160,Format du mois incorrect, N'oubliez pas de rajouter un "0" si vous �tes dans la tranche de Janvier � Septembre.`n`nExemple : 03 au lieu de 3
		GuiControl, Focus, ChoixMois
		Return
	}
	If Not RegExMatch(ChoixAnnee, "^((202)[0-9])$")
	{
		MsgBox,262160,Format de l"ann�e incorrect, Le format de l'ann�e doit �tre compos� de 4 chiffres`n`nExemple : 2014 au lieu de 14`n`nUniquement les dates de 2014 � 2019 peuvent �tre utilis�es.
		GuiControl, Focus, ChoixAnnee
		Return
	}

	If Not RegExMatch(ChoixHeure, "^([01][0-9]|2[0-3]):[0-5][0-9]$")
	{
		MsgBox,262160,Format de l'heure incorrect, Le format de l'heure doit �tre de la sorte : XX:XX.`n`nExemple : 08:23
		GuiControl, Focus, ChoixHeure
		Return
	}

	If (TicketSFR = "" and Type = "Routeur")
	{
		MsgBox,262160, Ticket SFR manquant, Merci d'indiquer le num�ro du ticket SFR.
		GuiControl, Focus, TicketSFR
		Return
	}
	GuiControlGet, EtatSFR, Enabled, SFR,
	GuiControlGet, EtatTicketSFR, Enabled, TicketSFR,
	If (EtatSFR = 1 and EtatTicketSFR = 1)
	{
		If Not RegExMatch(TicketSFR, "^((C)\d{8})$")
		{
			MsgBox,262160,Num�ro du ticket SFR incorrect, Le num�ro du ticket SFR n'est pas au bon format.`n`nExemple : C13560321
			GuiControl, Focus, TicketSFR
			Return
		}
	}
	If ChoixHeure = %HeureLancement%
	{
		MsgBox, 262196, Heure non chang�e, L'heure d'indisponiblit� est la m�me qu'� l'ouverture du programme !`n`nVoulez-vous vraiment envoyer le fait marquant avec comme heure d'indisponiblit� %ChoixHeure% ?
		IfMsgbox, No
		{
			GuiControl, Focus, ChoixHeure
			Return
		}
	}

;Destruction de l'interface graphique
Gui, Destroy

;On d�termine le type d'�quipement et sa criticit� pour ouvrir le FM en cons�quence (Message sp�cifique, appel astreinte op�rateur, etc...)
	If (Iso = "1" and InfoType = "Routeur") ;Site isol�  
	{
		Mode = Isol�
		VueJ = 1
		If infosite2 <> /
			SiteImpacte := infosite2
		Else If infosite1 <> /
			SiteImpacte := infosite1
		Else
			SiteImpacte := inforegion	
		Routeur := RegExReplace(ChoixEquipement, "(-RET-)\d{7}", "") ;R�cup�ration du nom court du routeur	
		If RegExMatch(Routeur, "(_X)",StartingPosition = 9)
		{
			RouteurX = %Routeur%
			RouteurY := RegExReplace(RouteurX, "(_X)", "_Y",StartingPosition = 9)
		}
		If RegExMatch(Routeur, "(_Y)",StartingPosition = 9)
		{
			RouteurY = %Routeur%
			RouteurX := RegExReplace(RouteurY, "(_Y)", "_X",StartingPosition = 9)
		}	
		FormatTime, AstreinteOperateur,, HH:mm
		Progress, w800 y%EcranProgress% fs13 M2 CW800000 CTFFFFFF zh0,Appelez l'astreinte op�rateur au : `n0 810 810 311`n`nLe site isol� est : %siteimpacte%,,Important, Verdana
	}
	Else If InfoType = Routeur ;Routeur seul
	{
		Mode = Routeur
		VueJ = 1
		Routeur := RegExReplace(ChoixEquipement, "(-RET-)\d{7}", "") ;R�cup�ration du nom court du routeur
	}
	Else If InfoType = Serveur de fichiers
	{
		Equipe = SN1_C1_EXPLOITATION	
		Equipement = Le serveur de fichiers
		Equipement2 = du serveur de fichiers
		Categorie = Autres
		Domaine = 00-Appli / Infra
		SousDomaine = Process-Faits Marquants
		Impact = 2
		Urgence = 1				
		VueJ = 1
		FormatTime, AstreinteOperateur,, HH:mm
		Progress, w800 y%EcranProgress% fs13 M2 CW800000 CTFFFFFF zh0, Appelez l'astreinte op�rateur au : `n0 810 810 311`n`nLe serveur de fichiers impact� est %ChoixEquipement%,,Important, Verdana
	}
		Else If InfoType = Borne Wifi
			{
			Equipe = SN2_R1_RESEAU
			Equipement = La borne wifi
			Equipement2 = de la borne wifi
			Categorie = Autres
			Domaine = 00-Appli / Infra
			SousDomaine = Process-Faits Marquants
			Impact = 4
			Urgence = 3
			VueJ = 1
			}
Else If (InfoType = "Switch" or InfoType = "Switch N3" or InfoType = "Switch Fibre SAN")
			{
			Equipe = SN2_R1_RESEAU
			Equipement = Le switch
			Equipement2 = du switch
			Categorie = Switch
			Domaine = 00-Appli / Infra
			SousDomaine = Process-Faits Marquants
			Impact = 4
			Urgence = 3
			VueJ = 1			
			}
Else If InfoType = Contr�leur de domaine
			{
			Equipe = SN1_C1_EXPLOITATION
			Equipement = Le contr�leur de domaine
			Equipement2 = du contr�leur de domaine
			Categorie = Autres
			Domaine = 00-Appli / Infra
			SousDomaine = Process-Faits Marquants
			Impact = 3
			Urgence = 2
			}	
Else
			{
			Equipe = SN2_R1_RESEAU
			Equipement = L'�quipement
			Equipement2 = de l'�quipement
			Categorie = Autres
			Domaine = 00-Appli / Infra
			SousDomaine = Process-Faits Marquants
			Impact = 4
			Urgence = 3
			}
Hotkey, LButton , Off ;D�sactivation de la copie automatique du num�ro de ticket SFR
;Affichage du message d'information en haut de l'�cran	
Gui, 2: -Caption +ToolWindow +AlwaysOnTop +0x400000
Gui, 2: Color, a00075
Gui, 2:font, s14, Berlin Sans FB
Gui, 2:Add, Text, x45 y7 Section w630 vInfo cFFFFFF, Ouvrez un nouvel incident depuis 'Gestion des incidents' dans Service Manager
Gui, 2:Add, Picture,x4 yp-6 h32 w32 Icon278, Shell32.dll
Gui, 2:Add, Text, x0 y0 w630 h35 Backgroundtrans vDeplacer GuiMove
Gui, 2:Show, y5 xCenter NoActivate h35,Information

;Si la case Service Manager est coch� on passe directement � ERICA V2
If SM = 1
	Goto, LancementERICAV2

;Si Service Manager est lanc� on active la fen�tre
IfWinExist, HP Service Manager
	WinActivate
Loop {
	CoordMode, Pixel, Screen:	
	PixElsearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, 0xFF00FF, 0, Fast
		If ErrorLevel = 0
			{
			MessageInfo("DOUBLE CLIQUEZ � droite du `'Num�ro d`'Incident`' pour pr�remplir la fiche", 650)
			Gui, 2:Color, A00075			
			Break
			}
	}
ClickGenerationSM:
KeyWait, LButton, D
KeyWait, LButton, U
KeyWait, LButton, D T0.4
If ErrorLevel
	Goto, ClickGenerationSM
IfWinNotActive, HP Service Manager
	Goto, ClickGenerationSM
Sleep, 100
Send, ^c
If RegExMatch(ClipBoard, "^((IM00)\d{7})$")
	Fiche := Clipboard
Else
 Goto, ClickGenerationSM
 
;Auto-remplissage de la fiche SM en fonction du type d'�quipement et sa criticit�
MessageInfo("Pr�remplissage en cours de la fiche Service Manager", 470)
Gui, 2:Color, 008409
If Mode = Routeur
{
Clipboard =
(
Bonjour,

Centreon nous retourne une indisponibilit� du routeur %Routeur%.

Ticket SFR : %TicketSFR%

Merci de prendre en charge cet incident.

Cordialement
)

	Send, {TAB}SN1_R1_EXPLOITATION{TAB 5}SUPERVISION`,{SPACE 2}(U146876){TAB 5}%InfoService%{TAB 4}SFR %TicketSFR%{TAB}%ChoixEquipement%{TAB 6}00-Appli / Infra{TAB 2}%ChoixJour%/%ChoixMois%/%ChoixAnnee% %ChoixHeure%:00{TAB 2}Process-Faits Marquants{TAB 2}%ChoixJour%/%ChoixMois%/%ChoixAnnee% %ChoixHeure%:01{TAB 2}4{TAB 3}3{TAB 2}[FM] Le routeur %Routeur% ne r�pond plus au ping{TAB}
	Send, ^v
}
Else If Mode = Isol�
	{
	Clipboard =
	(
Bonjour,

Centreon nous retourne une indisponibilit� des 2 routeurs suivants :
- %RouteurX%
- %RouteurY%
	
Par cons�quent, le site %siteimpacte% est isol� du r�seau.
	
Ticket SFR : %TicketSFR%
	
Merci de prendre en charge cet incident.
	
Cordialement
	)
	
	Send, {TAB}SN2_R1_RESEAU{TAB 5}SUPERVISION`,{SPACE 2}(U146876){TAB 5}%InfoService%{TAB 4}SFR %TicketSFR%{TAB}%ChoixEquipement%{TAB 6}00-Appli / Infra{TAB 2}%ChoixJour%/%ChoixMois%/%ChoixAnnee% %ChoixHeure%:00{TAB 2}Process-Faits Marquants{TAB 4}2{TAB 3}2{TAB 2}[FM] Le site %siteimpacte% est isol� du r�seau{TAB}
	Send, ^v
	}
Else
	{
	Clipboard =
	(
Bonjour,

Centreon nous retourne une indisponibilit� %Equipement2% %ChoixEquipement%.

Merci de prendre en charge cet incident.

Cordialement
	)		
	Send, {TAB}%Equipe%{TAB 5}SUPERVISION`,{SPACE 2}(U146876){TAB 5}%InfoService%{TAB 5}%ChoixEquipement%{TAB 6}%Domaine%{TAB 2}%ChoixJour%/%ChoixMois%/%ChoixAnnee% %ChoixHeure%:00{TAB 2}%SousDomaine%{TAB 4}%Impact%{TAB 3}%Urgence%{TAB 2}[FM] %Equipement% %ChoixEquipement% ne r�pond plus au ping{TAB}
	Send, ^v
		}
		
If Mode = Isol�
	{
	Send,{TAB 3}{Enter}
	Sleep, 250
	SendInput, {TAB}%ChoixJour%/%ChoixMois%/%ChoixAnnee% %AstreinteOperateur%:00
	}
MessageInfo("V�rifiez le contenu de l'incident puis appuyez sur la touche `'Ctrl Droit`' pour le sauvegarder", 760)
Gui, 2:Color, A00075
KeyWait, RControl, D
MessageInfo("Enregistrement de la fiche du fait marquant", 410)
Gui, 2:Color, 008409
;Gui, 2:Show, w340 h35 ,Information - Ajout de 70
WinWait, HP Service Manager
WinActivate, HP Service Manager
Send, ^+{F4}
Sleep, 2500
If VueJ = 1
	{
		MessageInfo("Cochez la case `'Vue en journali�re`' placez votre curseur dans 'Nouvelle mise a jour' et appuyez sur la touche `'Ctrl Droit`' pour sauvegarder", 1000)
		Gui, 2:Color, A00075
		EtapeSuivante = LancementEricaV2
		KeyWait, RControl, D
		Sleep, 300
		Send, Coche de la case 'Vue en journali�re'
		Sleep, 500
		Send, ^+{F4}
		Sleep, 2000
	}		
If Ackno = 1
	{
	MessageInfo("Mise en place de l'Acknowledge automatique", 420)
	Gui, 2:Color, 008409
	RunWait, %A_ScriptDir%\img\plink.exe -ssh supervsisnp -P 22 -l sea -pw O45!charly -hostkey b8:99:26:d9:e7:f9:8d:14:ad:07:51:ab:4e:7f:ff:bc "echo '%ChoixEquipement%;Voir FM %Fiche%;TOUS;%A_Username%' > /exploit/local/fifo/acknowledge"
	If ErrorLevel
		{
		MsgBox, 262160, Erreur, L'Acknowledge n'a pas pu �tre mis en place.`nMerci de le mettre en place manuellement.
		Goto, LancementERICAV2
		}
	If Mode = Isol�
		{
		If RegExMatch(ChoixEquipement, "(_X)",StartingPosition = 9)
			 ChoixEquipementAckno := RegExReplace(ChoixEquipement, "(_X)", "_Y",StartingPosition = 9)
		If RegExMatch(ChoixEquipement, "(_Y)",StartingPosition = 9)
			 ChoixEquipementAckno := RegExReplace(ChoixEquipement, "(_Y)", "_X",StartingPosition = 9)
		RunWait, %A_ScriptDir%\img\plink.exe -ssh supervsisnp -P 22 -l sea -pw O45!charly -hostkey b8:99:26:d9:e7:f9:8d:14:ad:07:51:ab:4e:7f:ff:bc "echo '%ChoixEquipementAckno%;Voir FM %Fiche%;TOUS;%A_Username%' > /exploit/local/fifo/acknowledge"	 
		}
	}

LancementERICAV2:
MessageInfo("Lancement et authentification � ERICA V2", 400)
Gui, 2:Color, 008409
Gosub, EricaV2
WinWait, ERICA V2
clickfmErica:
MessageInfo("DOUBLE CLIQUEZ dans le `'Champ Vide`' sous ERICA V2", 490)
Gui, 2:Color, A00075
clickfmcreation:
KeyWait, LButton, D
KeyWait, LButton, U
KeyWait, LButton, D T0.4
If ErrorLevel
	Goto, clickfmcreation
IfWinNotActive, ERICA V2
	Goto, clickfmcreation
SendInput, %ChoixEquipement%
MessageInfo("CLIQUEZ sur l'�quipement impact�", 340)
KeyWait, LButton, D
clickSelection:
CoordMode, Pixel, Screen:
ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *80 %A_ScriptDir%\img\Description.png
If ErrorLevel
     Goto, clickSelection	 
MessageInfo("DOUBLE CLIQUEZ dans le champ `'Description de l'incident`' sous ERICA V2", 640)
clickfmstart:
KeyWait, LButton, D
KeyWait, LButton, U
KeyWait, LButton, D T0.4
If ErrorLevel
	Goto, clickfmstart
IfWinNotActive, ERICA V2
	Goto, clickfmstart

;Saisi du texte en fonction du mode (Routeur, Site isol� ou Autre)
If Mode = Routeur
	SendInput, Le routeur %Routeur% ne r�pond plus au ping
Else If Mode = Isol�
	SendInput, Le site %siteimpacte% est isol� du r�seau
Else
	SendInput, %Equipement% %ChoixEquipement% ne r�pond plus au ping
SendInput,{TAB 2}%Fiche%
Sleep, 100
Loop 4 {
	Send, +{TAB}
}
Send, {ENTER}
Sleep, 1000
MessageInfo("DOUBLE CLIQUEZ dans le champ `'IMPACT`'", 410)
clicketape:
KeyWait, LButton, D
KeyWait, LButton, U
KeyWait, LButton, D T0.4
if ErrorLevel = 1
	Goto, clicketape
If Mode = Routeur
	SendInput, Le routeur %Routeur% ne r�pond plus au ping{TAB}Analyse en cours{TAB}Ticket SFR : %TicketSFR%{TAB}
Else If Mode = Isol�
	SendInput, Le site %siteimpacte% est isol� du r�seau{TAB}Analyse en cours{TAB}Ticket SFR : %TicketSFR%{TAB}
Else
	SendInput, %Equipement% %ChoixEquipement% ne r�pond plus au ping{TAB 2}Analyse en cours{TAB}
Sleep, 500
Send, {ENTER}
Sleep, 1500
If Mode = Isol�
	Goto, RouteurManquant
else
	{
		Loop 6 {
			Send, +{TAB}
		}
		Send, {ENTER}
	}
ExitApp	

RouteurManquant:
Loop 10 {
	Send, +{TAB}
}
Send, {ENTER}
MessageInfo("R�cup�ration automatique du 2�me routeur li� au fait marquant", 560)
Gui, 2:Color, 008409
Sleep, 1500
RegExMatch(ChoixEquipement, "^(.{11})", RouteurManquant)
Send, {TAB 7}
SendInput, %RouteurManquant%
Sleep, 1000
VerifParc:
CoordMode, Pixel, Screen:
ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *80 %A_ScriptDir%\img\Parc.png
	If ErrorLevel
		Goto, VerifParc
FoundX := (FoundX + 40)
FoundY := (FoundY + 50)
Click, %FoundX%, %FoundY%
Click, %FoundX%, %FoundY%
Sleep, 500
ClickEnregistrer:
WinActivate, ERICA V2
Send, {END}
CoordMode, Pixel, Screen:
ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *80 %A_ScriptDir%\img\Enregistrer.png
	If ErrorLevel
		Goto, ClickEnregistrer
FoundX := (FoundX + 20)
FoundY := (FoundY + 10)
Click, %FoundX%, %FoundY%
Sleep, 2000
Loop 4 {
	Send, +{TAB}
}
Send, {ENTER}
ExitApp

!�::
EricaV2:
IfExist, %fichierconfig%
{
	IniRead, MDP, %fichierconfig%, MDP, AD
	ADDECRYPT := % Crypt.Encrypt.StrDecrypt(MDP, A_Username, 7, 6)
	Run, D:\Users\%A_Username%\Documents\Portable\FFSec\FirefoxPortable.exe http://opera/ericav2/id_menu=233
	Sleep, 2000
	WinActivate	
	Loop 400 {
	IfWinExist, ATOS | Portail Opera
		{
		Sleep, 1000	
		WinActivate
		WinMaximize
		SendInput, %A_Username%
		Send, {TAB}^a
		SendInput, {Raw}%ADDECRYPT%
		Send, {ENTER}
		Sleep, 300
		IfWinExist, Saisie semi-automatique
			{
			WinActivate, Saisie semi-automatique
			Send, o
			}
		WinWait, Portail,,5
		WinActivate
		Sleep, 200
		Run, D:\Users\%A_Username%\Documents\Portable\FFSec\FirefoxPortable.exe http://opera/ericav2/id_menu=233
		Sleep, 2000
		Break
		}	
	IfWinExist, ERICA V2
		{
		WinActivate
		WinMaximize
		Break
		}	
	}
}	
Return


ContactSFR:
Gui, Submit, Nohide
RegExMatch(ChoixEquipement, "(\d{7})", MasterID)
If MasterID =
	MasterID = /
RouteurSelect := RegExReplace(ChoixEquipement, "(-RET-)\d{7}", "")
Gui, 3:Destroy
Gui, 3:+ToolWindow +AlwaysOnTop
Gui, 3:Color, ffffff
If InfoType = Routeur
{
Gui, 3:Font, s16 c000000, Arial Black
Gui, 3:Add, Text, w350 CENTER, %RouteurSelect%
Gui, 3:Font, s13 bold c0000FF, Segoe UI Semibold
Gui, 3:Add, Text, w300 ,Master ID : %MasterID%
}
Gui, 3:Font, s13 bold cB40404, Segoe UI Semibold
Gui, 3:Add, Text, w300 ,Num�ro de t�l�phone : 0 805 770 112
Gui, 3:Font, s13 bold c0B610B, Segoe UI Semibold
Gui, 3:Add, Text, w300 ,Num�ro de contrat : 109283
Gui, 3:Font, s13 bold c000000, Segoe UI Semibold
Gui, 3:Add, Text, w300 ,Soci�t� : RTE
Gui, 3:Font, s13 bold c4C0B5F, Segoe UI Semibold
Gui, 3:Add, Text, w300 ,Quadrigramme : A71Q
Gui, 3:Show, AutoSize,Hotline SFR (7/7 24h/24h)
Return

Ping:
GuiControlGet, ChoixEquipement
GuiControl,,Ping,Ping en cours...
GuiControl, Disable, ChoixEquipement
GuiControl, Disable, Ping
GuiControl, Disable, Envoyer
GuiControl, Disable, Ackno
GuiControl, Disable, SM
EquipementSelection := RegExReplace(ChoixEquipement, "(-RET-)\d{7}", "")
LogFile := A_Temp "\Ping.log"
Runwait, %comspec% /c ping -n 1 %infoip%>%LogFile%, , hide
FileRead, Contents, %LogFile%
FileDelete, %LogFile%
If InStr(Contents, "perdus = 1") or InStr(Contents, "Impossible") and InStr(Contents, "perdus = 0")
	{
	GuiControl,,Ping,PING KO
	MsgBox,262160,Information, %EquipementSelection% ne r�pond pas au ping !
	}
Else	
	{
	GuiControl,,Ping,PING OK
	Msgbox,262208, Information, %EquipementSelection% r�pond au ping !
	}
GuiControl, Enable, ChoixEquipement
GuiControl, Enable, Ping
GuiControl, Enable, Envoyer
GuiControl, Enable, Ackno
GuiControl, Enable, SM
GuiControl,,Ping,Ping de l'�quipement
Return

;Ferme la fen�tre de contact Hotline SFR
2GuiClose:
Gui, 2:Destroy
Return

;Relance l'application
Relancer:
Gui, Destroy
Reload
Return

;Quitte le programme
GuiClose:
Quitter:
Gui, Destroy
ExitApp

;Permet de d�placer le GUI en maintenant le clic dessus
uiMove:
PostMessage, 0xA1, 2,,, A 
Return

;Fonction mettant � jour la barre d'information en haut de l'�cran
MessageInfo(Texte, Largeur) {
Gui, 2: Color, %Couleur%
GuiControl, 2:text,Info, %Texte%
GuiControl, 2:Move, Info, w%Largeur%
GuiControl, 2:Move, Deplacer, w%Largeur%
Gui, 2:Show, NoActivate w%Largeur%,Information
}

;Fonctions n�cessaires � l'auto-completion
; ======================================================================================================================
CB_FindItem(HCB, String, Start) {
   ; CB_FINDSTRING = 0x014C
   SendMessage, 0x014C, % --Start, % &String, , ahk_id %HCB%
   Return ((ErrorLevel = "FAIL") || (ErrorLevel & 0x80000000)) ? 0 : ++ErrorLevel
}
; ======================================================================================================================
CB_GetItemText(HCB, Item) {
   ; CB_GETLBTEXT = 0x0148
   If (TextLength := CB_GetItemTextLength(HCB, Item)) {
      VarSetCapacity(ItemText, TextLength * 2, 0)
      SendMessage, 0x0148, % --Item, % &ItemText, , ahk_id %HCB%
      VarSetCapacity(ItemText, -1)
      Return ItemText
   }
}
; ======================================================================================================================
CB_SelectItem(HCB, Item) {
   ; CB_SETCURSEL = 0x014E
   SendMessage, 0x014E, % --Item, 0, , ahk_id %HCB%
   Return ((ErrorLevel = "FAIL") || (ErrorLevel & 0x80000000)) ? 0 : ErrorLevel
}
; ======================================================================================================================
CB_SetEditSel(HCB, Start, End) {
   ; CB_SETEDITSEL = 0x0142
   Selection := ((Start - 1) & 0xFFFF) | (((End - 1) & 0xFFFF) << 16)
   SendMessage, 0x0142, 0, %Selection%, , ahk_id %HCB%
   Return ((ErrorLevel = "FAIL") || (ErrorLevel & 0x80000000)) ? False : True
}
; ======================================================================================================================
CB_GetItemTextLength(HCB, Item) {
   ; CB_GETLBTEXTLEN = 0x0149
   SendMessage, 0x0149, % --Item, 0, , ahk_id %HCB%
   Return ((ErrorLevel = "FAIL") || (ErrorLevel & 0x80000000)) ? 0 : ErrorLevel
}
; ======================================================================================================================