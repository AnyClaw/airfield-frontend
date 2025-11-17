<script setup>
import { ref } from 'vue'
import axios from 'axios'

import Header from '@/components/Header.vue';

const login = ref('')
const password = ref('')
const isLoading = ref(false)

async function auth() {
    if (!login.value || !password.value) {
        alert('Заполните все поля')
        return
    }

    isLoading.value = true

    try {
        const response = await axios.post('http://localhost:8080/login', {
            login: login.value,
            password: password.value
        })

        localStorage.setItem('authToken', response.data.token)

        alert('Успешная авторизация!')
    } catch(error) {
        alert(error)
        isLoading.value = false
    }
}
</script>

<template>
    <Header />
    <main>
        <div class="content">
            <input v-model="login" placeholder="Логин">
            <input v-model="password" placeholder="Пароль">
            <div class="button-section">
                <button @click="auth" :disabled="isLoading">Войти</button>
            </div>
        </div>
    </main>
</template>

<style scoped>
main {
    display: flex;
    justify-content: center;
    align-items: center;
}

.content {
    min-height: 100%;
    border: 5px solid silver;
    border-radius: 10px;
    background-color: white;
    padding: 5px 10px;
    margin-top: 200px;
}

input {
    width: 100%;
    border-radius: 5px;
    margin: 10px 0;
    box-sizing: border-box;
    padding: 5px;
}

.button-section {
    width: 100%;
    display: flex;
    justify-content: center;
}

button {
    padding: 5px;
}

img {
    cursor: pointer;
}
</style>