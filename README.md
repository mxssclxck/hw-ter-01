# Никоноров Денис FOPS-6
# Домашнее задание к занятию «Основы Terraform. Yandex Cloud»

### Задание 1
В качестве ответа всегда полностью прикладывайте ваш terraform-код в git.

4. Инициализируйте проект, выполните код. Исправьте намеренно допущенные синтаксические ошибки. Ищите внимательно, посимвольно. Ответьте, в чём заключается их суть.
5. Ответьте, как в процессе обучения могут пригодиться параметры ```preemptible = true``` и ```core_fraction=5``` в параметрах ВМ. Ответ в документации Yandex Cloud.

В качестве решения приложите:

- скриншот ЛК Yandex Cloud с созданной ВМ;
![alt text](img/1.png)

- скриншот успешного подключения к консоли ВМ через ssh. К OS ubuntu необходимо подключаться под пользователем ubuntu: "ssh ubuntu@vm_ip_address";
![alt text](img/2.png)

- ответы на вопросы.

Ответ: preemptible = true дает возможность останавливать наши ВМ, core_fraction=5. ВМ с уровнем производительности меньше 100% предназначены для запуска приложений, не требующих высокой производительности и не чувствительных к задержкам. Таким образом, данные настройки помогают нам экономить денежные средства при обучении.

Jбнаружены две ошибки.

platform_id = "standart-v4" - такой платформы у Yandex нет. Ставлю platform_id = standart-v1

У Yandex можно минимально ставить от двух vCPU. Ставлю cores = 2

---

### Задание 2

1. Изучите файлы проекта.
2. Замените все хардкод-**значения** для ресурсов **yandex_compute_image** и **yandex_compute_instance** на **отдельные** переменные. К названиям переменных ВМ добавьте в начало префикс **vm_web_** .  Пример: **vm_web_name**.
2. Объявите нужные переменные в файле variables.tf, обязательно указывайте тип переменной. Заполните их **default** прежними значениями из main.tf. 
3. Проверьте terraform plan. Изменений быть не должно. 

**Ответ.**
<details><summary>variables update (фрагмент)</summary>

```tf
###wm_web
variable "os_image" {
  type = string
  default = "ubuntu-2004-lts"
  description = "OS iso image Linux"
}
variable "platformver" {
  type = string
  default = "standard-v1"
  description = "Version platform version"
}
variable "name_vm" {
  type = string
  default = "netology-develop-platform-web"
  description = "Set VM name"
}
variable "cores_vm" {
  type = number
  default = 2
  description = "VM vCPU"
}
variable "memory_vm" {
  type = number
  default = 1
  description = "VM RAM (Gb)"
}
variable "core_fractioin_vm" {
  type = number
  default = 5
  description = "VM Core fraction (%)"  
}
```
</details>
<details><summary>main update (фрагмент)</summary>

```tf
resource "yandex_vpc_subnet" "develop" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}


data "yandex_compute_image" "ubuntu" {
  family = var.os_image
}
resource "yandex_compute_instance" "platform" {
  name        = var.name_vm
  platform_id = var.platformver
  resources {
    cores = var.cores_vm
    memory = var.memory_vm
    core_fraction = var.core_fractioin_vm
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }
}
```
</details>

![alt text](img/3.png)

---

### Задание 3

1. Создайте в корне проекта файл 'vms_platform.tf' . Перенесите в него все переменные первой ВМ.
2. Скопируйте блок ресурса и создайте с его помощью вторую ВМ в файле main.tf: **"netology-develop-platform-db"** ,  cores  = 2, memory = 2, core_fraction = 20. Объявите её переменные с префиксом **vm_db_** в том же файле ('vms_platform.tf').
3. Примените изменения.

**Ответ.**
<details><summary>vms_platform.tf</summary>

```tf

resource "yandex_compute_instance" "platform2" {
  name        = var.name_vm_db
  platform_id = var.platformver_vm_db
  resources {
    cores         = var.cores_vm_db
    memory        = var.memory_vm_db
    core_fraction = var.core_fractioin_vm_db
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }
}
###wm_db
variable "name_vm_db" {
  type        = string
  default     = "netology-develop-platform-db"
  description = "VM name"
}

variable "platformver_vm_db" {
  type        = string
  default     = "standard-v1"
  description = "VM platform"
}

variable "cores_vm_db" {
  type        = number
  default     = 2
  description = "VM vCPU"
}

variable "memory_vm_db" {
  type        = number
  default     = 2
  description = "VM RAM (Gb)"
}

variable "core_fractioin_vm_db" {
  type        = number
  default     = 20
  description = "VM core fraction (%)"
}
```

</details>

---

## Задание 4

1. Объявите в файле outputs.tf output типа map, содержащий { instance_name = external_ip } для каждой из ВМ.
2. Примените изменения.

В качестве решения приложите вывод значений ip-адресов команды ```terraform output```.

**Ответ.**


<details><summary>outputs.tf</summary>

```tf

output "info_vm_web" {
  value = { for vm in yandex_compute_instance.platform[*] : vm.name =>  vm.network_interface[0].nat_ip_address }
}

output "info_vm_db" {
  value = { for vm in yandex_compute_instance.platform2[*] : vm.name =>  vm.network_interface[0].nat_ip_address }
}
```
</details>

![alt text](img/4.png)

---

### Задание 5

1. В файле locals.tf опишите в **одном** local-блоке имя каждой ВМ, используйте интерполяцию ${..} с несколькими переменными по примеру из лекции.
2. Замените переменные с именами ВМ из файла variables.tf на созданные вами local-переменные.
3. Примените изменения.

**Ответ.**

<details><summary>locals.tf</summary>

```tf
locals {
  name_web = "${var.vpc_name}-${var.name_vm_web}-cf${var.core_fractioin_vm_web}"
  name_db = "${var.vpc_name}-${var.name_vm_db}-cf${var.core_fractioin_vm_db}"
}
```
</details>

Значения в **yandex_compute_instance**:
 - `name        = local.name_web`
 - `name        = local.name_db`

![alt text](img/5.png)


---

### Задание 6

1. Вместо использования трёх переменных  ".._cores",".._memory",".._core_fraction" в блоке  resources {...}, объедините их в переменные типа **map** с именами "vm_web_resources" и "vm_db_resources". В качестве продвинутой практики попробуйте создать одну map-переменную **vms_resources** и уже внутри неё конфиги обеих ВМ — вложенный map.
2. Также поступите с блоком **metadata {serial-port-enable, ssh-keys}**, эта переменная должна быть общая для всех ваших ВМ.
3. Найдите и удалите все более не используемые переменные проекта.
4. Проверьте terraform plan. Изменений быть не должно.

**Ответ.**

Все более не используемые переменные проекта удалены.

<details><summary>variables.tf (фрагмент)</summary>

```tf

variable "vms_resources" {
  type = map(object({
    cores = number
    memory = number
    core_fraction = number
  }))
  default = {
    vm_web_resources = {
      cores = 2
      memory = 1
      core_fraction = 5 
    }
    vm_db_resources = {
      cores = 2
      memory = 2
      core_fraction = 20
    }
  }

}

###ssh vars

variable "vms_metadata" {
  type = object({
    serial-port-enable = number
    ssh-keys = string 
  })
  default = {
    serial-port-enable = 1
    ssh-keys = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG81pIeDIjO1qiw0xI6rHs5txcF79JFs6zJULK6YdYCo thegamer8161@thegamer8161-MaiBook-M"  
  }  
}
```

</details>

<details><summary>yandex_compute_instance (пример с vm_web) </summary>

```tf
resource "yandex_compute_instance" "platform" {
  name        = local.name_web
  platform_id = var.platformver
  
  resources {
    cores = var.vms_resources["vm_web_resources"]["cores"]
    memory = var.vms_resources["vm_web_resources"]["memory"]
    core_fraction = var.vms_resources["vm_web_resources"]["core_fraction"]
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  metadata = {
    serial-port-enable = var.vms_metadata["serial-port-enable"]
    ssh-keys           = var.vms_metadata["ssh-keys"]
  }
}
```
</details>

---

## Дополнительное задание (со звёздочкой*)

**Настоятельно рекомендуем выполнять все задания со звёздочкой.**   
Они помогут глубже разобраться в материале. Задания со звёздочкой дополнительные, не обязательные к выполнению и никак не повлияют на получение вами зачёта по этому домашнему заданию. 

### Задание 7*

Изучите содержимое файла console.tf. Откройте terraform console, выполните следующие задания: 

1. Напишите, какой командой можно отобразить **второй** элемент списка test_list.
2. Найдите длину списка test_list с помощью функции length(<имя переменной>).
3. Напишите, какой командой можно отобразить значение ключа admin из map test_map.
4. Напишите interpolation-выражение, результатом которого будет: "John is admin for production server based on OS ubuntu-20-04 with X vcpu, Y ram and Z virtual disks", используйте данные из переменных test_list, test_map, servers и функцию length() для подстановки значений.

В качестве решения предоставьте необходимые команды и их вывод.

**Ответ.**

1.
```
> local.test_list[1]
"staging"
```
2. 
```
> length(local.test_list)
3
```
3.
```
> local.test_map["admin"]
"John"
```
4.
```
"${local.test_map["admin"]} is admin for ${local.test_list[2]} server based on OS ${local.servers[local.test_list[2]].image} with ${local.servers[local.test_list[2]].cpu} vCPU, ${local.servers[local.test_list[2]].ram} ram, ${length(local.servers[local.test_list[2]].disks)} virtual disks"

"John is admin for production server based on OS ubuntu-20-04 with 10 vCPU, 40 ram, 4 virtual disks"
```
![alt text](img/6.png)

---
### Правила приёма работы

В git-репозитории, в котором было выполнено задание к занятию «Введение в Terraform», создайте новую ветку terraform-02, закоммитьте в эту ветку свой финальный код проекта. Ответы на задания и необходимые скриншоты оформите в md-файле в ветке terraform-02.

В качестве результата прикрепите ссылку на ветку terraform-02 в вашем репозитории.

**Важно. Удалите все созданные ресурсы**.


### Критерии оценки

Зачёт ставится, если:

* выполнены все задания,
* ответы даны в развёрнутой форме,
* приложены соответствующие скриншоты и файлы проекта,
* в выполненных заданиях нет противоречий и нарушения логики.

На доработку работу отправят, если:

* задание выполнено частично или не выполнено вообще,
* в логике выполнения заданий есть противоречия и существенные недостатки. 

