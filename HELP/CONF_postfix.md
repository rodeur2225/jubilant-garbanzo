# Postfix

pour que centreon puisse vous envoyer des mails il lui faut un relay ,
pour cela nous utiliserons le service postfix, voici comment le configurer

acceder a la configuration comme cela :

```Shell
vim /etc/postfix/main.cf
```

ecrivez ou renseigner ou verifier ces lignes :


```cf
mail_owner = postfix

myhostname= centreon.[domaine].[tld]

mydomain = [domaine].[extension] #local internet domain name

myorigin = $myhostname

inet_intrerfaces = localhost
inet_protocols = all

mydestination = 

relayhost = [ [serveur de mail] ]:[port utilisé par le serveur mail]
```

une fois cela fais faite :

```Shell
restart service postfix
```

__END__
