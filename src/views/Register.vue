<script setup>
import Header from '@/components/Header.vue'
import Footer from '@/components/Footer.vue'

import { ref } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'

const name = ref('')
const login = ref('')
const password = ref('')
const confirmPassword = ref('')
const license = ref('')
const mileage = ref('')
const isLoading = ref(false)
const errorMessage = ref('')

const router = useRouter()

async function register() {
    if (!login.value || !password.value) {
        errorMessage.value = 'Заполните все поля'
        return
    }

    if (password.value !== confirmPassword.value) {
        errorMessage.value = 'Пароли не совпадают'
        console.log(`${password} != ${confirmPassword}`)
        return
    }

    isLoading.value = true

    try {
        const response = await axios.post('http://localhost:8080/register', {
            username: name.value,
            login: login.value,
            password: password.value,
            license: license.value,
            mileage: mileage.value
        })

        errorMessage.value = ''

        isLoading.value = false

        alert('Успешная регистрация!')

        router.push({name: 'Planes'})
    } catch(error) {
        console.log(error)
        errorMessage.value = error.response.data
        isLoading.value = false
    }
}
</script>

<template>
    <body class="page">
        <Header></Header>
        <main class="main">
            <div class="main-form">
                <ul class="form-rows">
                    <h1 class="registratia">Регистрация</h1>
                    <li class="form-item">
                        <label for="name" class="form-label">Имя:</label>
                        <input v-model="name" type="text" id="name" placeholder="Введите имя" class="input">
                    </li>
                    <li class="form-item">
                        <label for="login" class="form-label">Логин:</label>
                        <input v-model="login" type="text" id="login" placeholder="Введите логин" class="input">
                    </li>
                    <li class="form-item">
                        <label for="password" class="form-label">Пароль:</label>
                        <input v-model="password" type="password" id="password" placeholder="Введите пароль" class="input">
                    </li>
                    <li class="form-item">
                        <label for="confirm_password" class="form-label">Подтвердите пароль:</label>
                        <input v-model="confirmPassword" type="password" id="confirm_password" placeholder="Подтвердите пароль" class="input">
                    </li>
                    <li class="form-item">
                        <label for="license" class="form-label">Номер лицензии:</label>
                        <input  v-model="license" type="text" id="license" placeholder="Введите номер лицензии" class="input">
                    </li>
                    <li class="form-item">
                        <label for="flight_hours" class="form-label">Налёт (часы):</label>
                        <input v-model="mileage" type="number" id="flight_hours" placeholder="Введите ваш налет (в часах)" class="input">
                    </li>
                    <li class="form-item" v-show="errorMessage.length > 0">
                        <label class="form-label error-section">{{ errorMessage }}</label>
                    </li>
                    <li class="form-button">
                        <button class="registration-button" @click="register" :disabled="isLoading">Зарегистрироваться</button>
                    </li>
                </ul>
            </div>
        </main>
        <Footer></Footer>
    </body>

    <!-- <main class="page">
        <Header/>
        <Form>
            <div class="center">Регистрация</div>
            <input v-model="name" placeholder="Введите имя">
            <input v-model="login" placeholder="Введите логин">
            <input v-model="password" type="password" placeholder="Введите пароль">
            <input v-model="confirmPassword" type="password" placeholder="Подтвердите пароль">
            <input v-model="license" type="text" placeholder="Введите номер лицензии">
            <input v-model="mileage" type="text" placeholder="Введите ваш налёт (в часах)">
            <div v-show="errorMessage.length > 0" class="center" style="margin-bottom: 10px;">
                {{ errorMessage }}
            </div>
            <div class="center">
                <button :disabled="isLoading" @click="register">
                    Зарегестрироваться
                </button>
            </div>
        </Form>
    </main> -->
</template>

<style scoped>
.main {
  display: flex;
  justify-content: center;
  margin-top: 50px;
  margin-bottom: 50px;
}

.main-form {
  justify-content: center;
  border-radius: 6px;
  border: 4px solid #0066cc;
  width: 50%;
  padding: 25px;
  background: rgba(0, 0, 0, 0.2);
}

.registratia {
  text-align: center;
  font-weight: 600;
  color: #fff;
  text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.5);
}

.registration-button {
  display: inline-block;
  min-height: 30px;
  cursor: pointer;
  background: #0066cc;
  color: white;
  border: none;
  border-radius: 12px;
  transition: all 0.2s ease;
}

.registration-button:hover {
  transform: scale(1.1);
}

.form-rows {
  display: flex;
  flex-direction: column;
  width: 100%;
  gap: 15px;
  align-items: center;
}

.form-item {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.form-label {
  font-size: 14px;
  color: #fff;
  font-weight: 600;
  text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.5);
  margin-left: 5px;
}

.form-button {
  width: 100%;
  margin-top: 10px;
  display: flex;
  justify-content: center;
}

.input {
  width: 100%;
  min-height: 25px;
  border: 2px solid #000;
  padding: 5px;
  border-radius: 4px;
  text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.2);
  background: rgba(255, 255, 255, 0.9);
}

.input:focus {
  outline: none;
  border-color: #1E90FF;
  background: white;
}

.error-section {
    text-align: center;
    color: rgb(255, 0, 0);
}
</style>