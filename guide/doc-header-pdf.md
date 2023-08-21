---
title: |
    | The EMANE GUIDE
geometry: margin=1in
documentclass: book
classoption:
    - openany
header-includes:
    - \usepackage{titling}
    - \pretitle{\begin{center}
      \includegraphics[width=3in,height=3in]{images/adjacentlink.png}\\
      \url{https://adjacentlink.com}
      \vspace{1.5cm}\LARGE\\}
    - \posttitle{\end{center}
       \vspace{5cm}\scriptsize
       \noindent\makebox[\textwidth][c]{
       \fbox{
       \begin{minipage}{6in}
       Copyright \textcopyright\ 2014-2023 - Adjacent Link LLC, Bridgewater, New Jersey\\
       \smallskip\\
       Except where otherwise noted, this work (the \textit{EMANE Guide}) is licensed under 
       \href{https://creativecommons.org/licenses/by/4.0/}{Creative Commons Attribution 4.0 International License}.\\
       \url{https://creativecommons.org/licenses/by/4.0/}\\
       \smallskip\\
       \textbf{All source code accompanying the \textit{EMANE Guide} is released under the
       following BSD 3-clause license}:\\
       \smallskip\\
        \noindent\makebox[\textwidth][c]{
       \begin{minipage}{5.25in}
       Copyright \textcopyright~2014-2023 - Adjacent Link LLC, Bridgewater, New Jersey\\
       All rights reserved.\\
       \smallskip\\
       Redistribution and use in source and binary forms, with or without
       modification, are permitted provided that the following conditions
       are met:\\
        \begin{itemize}
        \item[*] Redistributions of source code must retain the above copyright
          notice, this list of conditions and the following disclaimer.
        \item[*] Redistributions in binary form must reproduce the above copyright
          notice, this list of conditions and the following disclaimer in
          the documentation and/or other materials provided with the
          distribution.
        \item[*] Neither the name of Adjacent Link LLC nor the names of its
          contributors may be used to endorse or promote products derived
          from this software without specific prior written permission.
        \end{itemize}
        \smallskip
        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
        ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
        LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
        FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
        COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
        INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
        BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
        CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
        LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
        ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
        POSSIBILITY OF SUCH DAMAGE.\\
         \end{minipage}}
        \smallskip\\
        \textbf{Portions of the \textit{EMANE Guide} derive from \textit{EMANE User Manual 0.8.1}
        which has the following license}:\\
        \smallskip\\
           \noindent\makebox[\textwidth][c]{
       \begin{minipage}{5.25in}
        Copyright \textcopyright\ 2013 - Adjacent Link LLC, Bridgewater, New Jersey\\
        Copyright \textcopyright\ 2012 - DRS CenGen, LLC, Bridgewater, New Jersey\\
        This work is licensed under the \href{http://creativecommons.org/licenses/by/3.0/}{Creative Commons Attribution 3.0 Unported License}.\\
        \url{http://creativecommons.org/licenses/by/3.0/}
           \end{minipage}}
        \end{minipage}}}}
    - \usepackage{fancyhdr}
    - \pagestyle{fancy}
    - \usepackage[firstpage]{draftwatermark}
    - \usepackage[skins]{tcolorbox}
---
\setcounter{tocdepth}{2}
\tableofcontents
