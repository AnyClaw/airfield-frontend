<script setup>
import { ref } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'

import Header from '@/components/Header.vue'
import Footer from '@/components/Footer.vue'

const login = ref('')
const password = ref('')
const isLoading = ref(false)
const errorMessage = ref('')

const router = useRouter()

async function auth() {
    if (!login.value || !password.value) {
        errorMessage.value = 'Заполните все поля'
        return
    }

    isLoading.value = true

    try {
        const response = await axios.post('http://localhost:8080/login', {
            login: login.value,
            password: password.value
        })

        localStorage.setItem('authToken', response.data.token)
        errorMessage.value = ''

        //TODO всплывашку
        alert('Успешная авторизация!')

        router.push({name: 'Planes'})
    } catch(error) {
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
                    <h1 class="vhod">Вход</h1>
                    <li class="form-item">
                        <label for="login" class="form-label">Логин:</label>
                        <input type="text" id="login" placeholder="Введите логин" class="input" v-model="login">
                    </li>
                    <li class="form-item">
                        <label for="password" class="form-label">Пароль:</label>
                        <input type="password" id="password" placeholder="Введите пароль" class="input" v-model="password">
                    </li>
                    <li class="form-item error-section" v-show="errorMessage.length > 0">
                        {{ errorMessage }}
                    </li>
                    <li class="form-button">
                        <button class="voiti-button" :disabled="isLoading" @click="auth">Войти</button>
                    </li>
                </ul>
            </div>
        </main>
        <Footer></Footer>
    </body>
</template>

<style scoped>
.main {
  display: flex;
  justify-content: center;
  margin-top: 50px;
  margin-bottom: 50px;
}

.main-form {
  margin-top: 50px;
  justify-content: center;
  border-radius: 6px;
  border: 4px solid #0066cc;
  width: 40%;
  padding: 25px;
  background: rgba(0, 0, 0, 0.2);
}

.vhod {
  text-align: center;
  font-weight: 600;
  color: #fff;
  text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.5);
}

.voiti-button {
  display: inline-block;
  min-width: 100px;
  min-height: 30px;
  cursor: pointer;
  background: #0066cc;
  color: white;
  border: none;
  border-radius: 12px;
  transition: all 0.2s ease;

  margin: 0 auto;
}

.voiti-button:hover {
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
  gap: 8px;
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
  text-align: center;
}

.input {
  width: 100%;
  min-height: 25px;
  border: 2px solid #000;
  border-radius: 4px;
}

.error-section {
    text-align: center;
    color: rgb(255, 0, 0);
}
</style>