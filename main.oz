functor
import
    QTk at 'x-oz://system/wp/QTk.ozf'
    System
    Application
    OS
    Browser
    Reader
    Open
define
%%% Easier macros for imported functions
    Browse = Browser.browse
    Show = System.show
    Dgram0 = {NewDictionary} %Dictionnaire global 0-gramme
    %Dgram1 est créé plus tard
    Put=Dictionary.put
    CondGet=Dictionary.condGet
    %%% Read File

    fun {GetLine IN_NAME N}
        {Reader.scan {New Reader.textfile init(name:IN_NAME)} N}
    end
   
    %%% Fonctions utiles venant du livre de référence  :

    fun{WordChar C} %Regarde si le Char C est une lettre/chiffre
        (&a=<C andthen C=<&z)orelse
        (&A=<C andthen C=<&Z)orelse
        (&0=<C andthen C=<&9)
    end

    fun{WordToAtom PW} %Renvoie le String en Atom dans le bon sens
        {StringToAtom {Reverse PW}}
    end

    fun{CharsToWords PW Cs} %Transforme une liste de strings avec caractères spéciaux en une liste de mots
        case Cs
        of nil andthen PW==nil then
            nil
        [] nil then
            [{WordToAtom PW}]
        [] C|Cr andthen{WordChar C} then
            {CharsToWords {Char.toLower C}|PW Cr}     
        [] C|Cr andthen PW==nil then
            {CharsToWords nil Cr}
        [] C|Cr then
            {WordToAtom PW}|{CharsToWords nil Cr}
        end
    end
    
    %%%%%%%%%%%%%  0-Gramme

    fun {Gram0 D} Lk %Return le mot, soit la key du mot avec le plus d'occurence
        fun {DicoK K Km} %Compares les items des keys donnés
            if (Km == nil)
            then K
            else
                if({Dictionary.get D Km} > {Dictionary.get D K}) then
                    Km 
                else
                    K
                end
            end
        end

        fun {Compare L K} %Regarde toutes les clés du dico et comparre leur item grâce à la fonction DicoK
            case L
            of H|T then
                {Compare T {DicoK H K}}
            [] nil then K
            end
        end
    in
        Lk = {Dictionary.keys D} %Liste des keys du dico
        {Compare Lk nil}
    end

    %%%%%%%%%%%% 1-Gramme

    fun {MpM Dg0 Dg1 L} %Prends mot par mot d'une liste de mots
        case L
        of H|T then
            {Put Dg0 H {CondGet Dg0 H 0}+1}
            case T
            of X|Y then
                {AddDico Dg1 H X}
                {MpM Dg0 Dg1 T}
            [] nil then {MpM Dg0 Dg1 T}
            end
        [] nil then Dg1
        end
    end

    proc {AddDico D Str1 Str2} D2 in %Créé les dicos dans les dicos qui comptent les occurences du mot suivant un certain mot
        {Put D Str1 {CondGet D Str1 {NewDictionary}}}
        D2 = {CondGet D Str1 0}
        {Put D2 Str2 {CondGet D2 Str2 0}+1}
    end

%%%%%%%%%%%%%%%% 2-Grammes

    fun {MpM2 D L}
       case L
       of H|T then
          case T
          of X|Y then
    	 case Y
    	 of V|W then
    	    {AddDico D {StringToAtom {List.append {AtomToString H} {AtomToString X}}} V}
    	    {MpM2 D T}
    	 [] nil then {MpM2 D T}
    	 end
          [] nil then D
          end
       [] nil then D
       end
    end



    % Thread de parsing basé sur les slides 33 du CM10


 fun {NewPortObject Init F}
        proc {Loop S State}
            case S of H|T then {Loop T {F H State}}
            [] nil then skip
            end 
        end
        P
    in 
        thread S in P = {NewPort S} {Loop S Init} end 
        P
    end

    fun {F L State}
        case L
        of put(T) then {MpM Dgram0 State {CharsToWords nil T}}
        [] take(Dico1g) then Dico1g = State Dico1g
        end
    end

    Dgram1 = {NewPortObject {NewDictionary} F} %Création du dictionnaire 1-gramme
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fun {NewPortObject2 Init2 F2}
        proc {Loop2 S2 State2}
            case S2 of H|T then {Loop2 T {F2 H State2}}
            [] nil then skip
            end 
        end
        P2
    in 
        thread S2 in P2 = {NewPort S2} {Loop2 S2 Init2} end 
        P2
    end

    fun {F2 L State2}
        case L
        of put2(T) then {MpM2 State2 {CharsToWords nil T}}
        [] take2(Dico2g) then Dico2g = State2 Dico2g
        end
    end

    Dgram2 = {NewPortObject2 {NewDictionary} F2} %Création du dictionnaire 2-grammes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%Lit un fichier ligne par ligne en entier et remplit les superDico 0 et 1

    proc{ReadFile FILENAME N }
        Line ListString in
        Line = {GetLine FILENAME N}
        if Line == none then 
            skip
        else 
        {Show Line}
            {Send Dgram1 put(Line)}
            {Send Dgram2 put2(Line)}
            {ReadFile FILENAME N+1}
        end
    end
    proc{ReadXFiles N Limit} %Marque le nombre de Fichiers texte qu'on veut lire
        if N == Limit then 
            {Browse {StringToAtom "Threads de lecture créés"}}
            skip 
        else
         thread {ReadFile "tweets/part_"#N#".txt" 1 } end
         {ReadXFiles N+1 Limit}
        end
    end

    {ReadXFiles 1 209} 

  
 %%%%%%%%% Interface Graphique
   
    %Permet juste de donner un mot et voir le 1-gramme de celui-ci


    Text1 Text2 Description=td(
        title: "Word Predicter"
        lr(
            text(handle:Text1 width:28 height:5 background:white foreground:black wrap:word)
	   			       button(text:"Prédire un mot" action:Press)   
	   )			       
       lr(		   						       
           text(handle:Text2 width:28 height:5 background:black foreground:white glue:w wrap:word)			       
	 )    
        action:proc{$}{Application.exit 0} end 
			       )
    
    proc {Press} Word in
       Word = {CharsToWords nil {Text1 getText(p(1 0) 'end' $)}}
       if (Word == nil) then {Text2 tk(insert 'end'  {StringToAtom {List.append "Le 0-Gramme des tweets est : " {AtomToString{Gram0 Dgram0}}}})} {Text2 tk(insert 'end' ' ')}
       elseif ({List.length Word} == 2) then
            local Dico WordDico in
             {Send Dgram2 take2(Dico)}
             WordDico = {Dictionary.condGet Dico  {StringToAtom {List.append {AtomToString {List.nth Word 1}} {AtomToString {List.last Word}}}} nil}
             case WordDico
                 of nil then {Browse {StringToAtom "Ces mots ne siéent pas à Trump, trouvez en des meilleurs !"}}
                 else {Text2 tk(insert 'end'  {Gram0 WordDico})} {Text2 tk(insert 'end' ' ')} end
             end
       else
            local Dico WordDico in
             {Send Dgram1 take(Dico)}
             WordDico = {Dictionary.condGet Dico {List.last Word} nil}
             case WordDico
                 of nil then {Browse {StringToAtom "Ce mot ne sied pas à Trump, trouvez en un meilleur !"}}
                 else {Text2 tk(insert 'end'  {Gram0 WordDico})} {Text2 tk(insert 'end' ' ')} end
             end
        end

    end
    
    W={QTk.build Description}
    {W show}
    {Browse {StringToAtom "Veuillez attendre la fin des threads dans le Browser"}}
    {Browse {StringToAtom {List.append "En attendant la fin, voici le 0-Gramme des premiers tweets lus : " {AtomToString{Gram0 Dgram0}}}}}
    {Browse {StringToAtom "A la fin de la compilation (durée estimée 3 minutes et 20 secondes),"}}
    {Browse {StringToAtom "Vous aurez 3 possibilités différentes :"}}
    {Browse {StringToAtom "Rien mettre et cliquer sur le bouton : Il affichera le 0-gramme "}}
    {Browse {StringToAtom "Mettre 1 mot et cliquer sur le bouton : Il affichera le 1-gramme du mot"}}
    {Browse {StringToAtom "Mettre 2 mots et cliquer sur le bouton : Il affichera le 2-grammes des mots"}}
    {Browse {StringToAtom "Si vous affichez plus, le 1-gramme du dernier mot sera affiché"}}
   

    %%%%%%%%%%%%% Autres méthodes de lecture de fichiers, la première n'est pas totalement fonctionnelle
    %%%%%%%%%%%%% mais peut être utilisé après quelques modifications. La seconde est bonne mais 
    %%%%%%%%%%%%% opti et "hardcodé"

    %%%%% Méthode Annexe de lecture de fichier 1 :

    %fun {ZeroExit N S}
    %    Result in
    %    case S of X|S2 then
    %    if N+X==0 then done
    %    else N+X  end
    %    end
    %end
    %fun{StartStream}
    %    Stream
    %    MainPort
    %    in
    %    {NewPort Stream MainPort}
    %    %{NewPort Input ThreadsActive}
    %    thread
    %       {TreatStream Stream 1 }
    %    end
    %    MainPort
    %end
    %proc{TreatStream Stream N}
    %    case Stream of nil then skip
    %    [] initiation|T then 
    %        {Send MainPort newThread}
    %        thread 
    %            %{Send Dgram1 put("test test pute")}
    %            {ReadFile "tweets/part_"#N#".txt" 1}{Browse niquttatziuhtuisdghiusdg} {Send MainPort minusThread}
    %        end
    %        {Show ThreadsTotal.count}
    %        {TreatStream T N+1}
    %    [] newThread|T then
    %        {Send ThreadCounter 1}
    %        {Send MainPort stateThreads}
    %        {TreatStream T N}
    %    [] minusThread|T then
    %        {Send ThreadCounter ~1}
    %        {Send MainPort stateThreads}
    %        {TreatStream T N }   
    %    [] stateThreads|T then Result in
    %        {Show Result}
    %        %TODO verifier etat threadcounter
    %        %if ThreadsTotal.count < 208 andthen ThreadsActive.count < 9 then
    %        %    {Show threading}
    %        %    {Send MainPort initiation}
    %        %    {TreatStream T N ThreadsActive ThreadsTotal}
    %        %elseif ThreadsTotal.count == 208 andthen ThreadsActive.count > 0 then
    %        %    {Show finishing}
    %        %    {Send MainPort stateThreads}
    %        %    {TreatStream T N ThreadsActive ThreadsTotal}
    %        %elseif ThreadsTotal.count < 208 andthen ThreadsActive.count == 9 then
    %        %    {Show threadCapFull}
    %        %    {Send MainPort stateThreads}
    %        %    {TreatStream T N ThreadsActive ThreadsTotal}
    %        %elseif ThreadsTotal.count == 208 andthen ThreadsActive.count == 0 then
    %        %    {Show done}
    %        %else
    %        %    {TreatStream T N }
    %        %end
    %    [] _|T then
    %        {TreatStream T N}
    %    end
    %end
    %MainPort = {StartStream}
    %{Send MainPort initiation}


%%%%% Méthode Annexe de lecture de fichier 2 :

    %X1 X2 X3 X4 X5 X6 X7 X8 X9 X10 X11 
    %thread  {ReadXFiles 1 20} X1 = unit end
    %thread  {ReadXFiles 20 40} X2 = X1 end
    %thread  {ReadXFiles 40 60} X3 = X2 end
    %thread  {ReadXFiles 60 80} X4 = X3 end
    %thread  {ReadXFiles 80 100} X5 = X4 end
    %thread  {ReadXFiles 100 120} X6 = X5 end
    %thread  {ReadXFiles 120 140} X7 = X6 end
    %thread  {ReadXFiles 140 160} X8 = X7 end
    %thread  {ReadXFiles 160 180} X9 = X8 end
    %thread  {ReadXFiles 180 200} X10 = X9 end
    %thread  {ReadXFiles 200 209} X11 = X10 end
    %{Wait X11}
    %{Show X11}

end


