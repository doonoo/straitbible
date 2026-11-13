
Name: straitbible
Version: 6.0
Release: 0
Group: Applications/Education
Summary: Open Source Bible Application 
License: GPLv3+
URL: https://github.com/doonoo/straitbible

%define _rpmdir ../SPECS
%define _rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm

%description
Strait Bible is an open source and free, multilingual Bible software, based on Unbound Bible by Vladimir Rybant.

%prep

%build

%install

%files
%{_bindir}/%{name}
%{_datadir}/applications/*.desktop
%{_datadir}/pixmaps/*
%{_datadir}/%{name}/bibles/*
%{_datadir}/%{name}/localization/*
%{_datadir}/%{name}/titles/*

%changelog
* Tue Mar 23 2021 Vladimir Rybant <vrybant@gmail.com> - 5.3-0
- Fixed some bugs.

* Tue Sep 01 2020 Vladimir Rybant <vrybant@gmail.com> - 5.1-0
- Fixed some bugs.
