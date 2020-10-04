# TP2 Malory BERGEZ-CASALOU

## 1. Déploiement simple

[Partie 1](vagrant/tp2/part1)

## 2. Re-Package

[Partie 2](vagrant/tp2/part2)

## 3. Multi-node deployment

[Partie 3](vagrant/tp2/part3)

## 4. Automation here we (slowly) come

[Partie 4](vagrant/tp2/part4)


pas faite, erreur de vagrant (j'ai changé de distrib entre temps)

```bash
malory@x260 vagrant]$ vagrant plugin install vagrant-vbguest
Installing the 'vagrant-vbguest' plugin. This can take a few minutes...
Vagrant failed to properly resolve required dependencies. These
errors can commonly be caused by misconfigured plugin installations
or transient network issues. The reported error is:

conflicting dependencies fog-libvirt (>= 0.6.0) and fog-libvirt (= 0.5.0)
  Activated fog-libvirt-0.5.0
  which does not match conflicting dependency (>= 0.6.0)

  Conflicting dependency chains:
    fog-libvirt (= 0.5.0), 0.5.0 activated

  versus:
    vagrant-libvirt (> 0), 0.1.0 activated, depends on
    fog-libvirt (>= 0.6.0)

```


