\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{ecelet}
          [12/13/2001]
\RequirePackage{ifthen}
\RequirePackage{graphicx}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{letter}}
\ProcessOptions
\LoadClass[a4paper]{letter}
\setlength{\textheight}{215mm}
\setlength{\textwidth}{160mm}
\setlength{\oddsidemargin}{0pt}
\setlength{\evensidemargin}{0pt}
\setlength{\topmargin}{-20pt}
\setlength{\headheight}{12pt}
\setlength{\headsep}{35pt}
\def\@{\kern 1.5truept}
\def\@@{\kern 2.0truept}
\def\@@@{\hskip 4.5truept}

%%--Begin------------------------------------------------Header_definition
\newsavebox{\deptname}
\savebox{\deptname}{
\begin{tabular}[c]{c}
{\scriptsize COMPUTER SCIENCE}
\end{tabular}
}

\newsavebox{\byulogo}
\savebox{\byulogo}{
\begin{tabular}[c]{c}
\includegraphics[scale=0.165]{BYU-logo}
\end{tabular}}


\newsavebox{\byucshead}
\sbox{\byucshead}
  {\parbox{\textwidth}{
    \vspace*{-12pt}
    \raisebox{0pt}{\usebox{\deptname}}
    \hspace*{85pt}
    \raisebox{0pt}{\usebox{\byulogo}}
    \hfill}}
    
%%--End--------------------------------------------------Header_definition

%%--Begin------------------------------------------------Footer_definition

\newsavebox{\csaddr}
\savebox{\csaddr}[\textwidth][c]%
        {{\scriptsize BRIGHAM YOUNG UNIVERSITY \@@ $\cdot$ \@@ 3361 TMCB  \@@ $\cdot$ \@@
         PROVO, UTAH 84602}}

\newsavebox{\csphone}
\savebox{\csphone}[\textwidth][c]%
        {{\scriptsize (801) 422-3027/FAX: (801) 422-0169}}

\newsavebox{\byucsfoot}
\sbox{\byucsfoot}
  {\parbox{\textwidth}{
    \raisebox{-6pt}{\usebox{\csaddr}}\\
    \raisebox{-9pt}{\usebox{\csphone}}}}

%%--End--------------------------------------------------Footer_definition

%%--Begin------------------------------------------ps@firstpage_definition
\renewcommand{\ps@firstpage}
  {\setlength{\headheight}{24pt}\setlength{\headsep}{30pt}%
   \renewcommand{\@oddhead}{\usebox{\byucshead}}
   \setlength{\footskip}{30pt}%
   \renewcommand{\@oddfoot}{\usebox{\byucsfoot}}
   \renewcommand{\@evenhead}{}
   \renewcommand{\@evenfoot}{}}
%%--End--------------------------------------------ps@firstpage_definition

%%--Begin-------------------------------------------ps@headings_definition
\renewcommand{\ps@headings}
  {\setlength{\headheight}{24pt}\setlength{\headsep}{30pt}%
   \renewcommand{\@oddhead}{}
   \setlength{\footskip}{30pt}%
   \renewcommand{\@oddfoot}{\usebox{\byucsfoot}}
   \renewcommand{\@evenhead}{\@oddhead}
   \renewcommand{\@evenfoot}{\@oddfoot}}
%%--End---------------------------------------------ps@headings_definition

%%--Begin-----------------------------------------------opening_definition
\newlength{\leftfield}
\setlength{\leftfield}{117mm}
\newlength{\rightfield}
\setlength{\rightfield}{43mm}

\renewcommand{\opening}[1]{\thispagestyle{firstpage}%
  \parbox[t]{\textwidth}
            {\parbox[b][3.5cm][c]{\textwidth}{\toname \hfill \@date \\
                                              \toaddress}}
  \vspace{2\parskip} #1 \par \nobreak}
%%--end-------------------------------------------------opening_definition
