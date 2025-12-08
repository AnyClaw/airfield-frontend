<script setup>
import { ref } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'

import Header from '@/components/Header.vue'
import Form from '@/components/Form.vue'

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
    <Header/>
    <Form>
        <div class="center">Вход</div>
        <input v-model="login" placeholder="Логин">
        <input v-model="password" type="password" placeholder="Пароль">
        <div v-show="errorMessage.length > 0" class="center" style="margin-bottom: 10px;">
            {{ errorMessage }}
        </div>
        <div class="center">
            <button @click="auth" :disabled="isLoading">Войти</button>
        </div>
    </Form>
</template>

<style scoped>

</style>