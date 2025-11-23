<script setup>
import Header from '@/components/Header.vue'
import Form from '@/components/Form.vue'

import { ref } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'

const name = ref('')
const login = ref('')
const password = ref('')
const confirmPassword = ref('')
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
            password: password.value
        })

        errorMessage.value = ''

        isLoading.value = false

        //TODO всплывашку
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
    <Header/>
    <Form>
        <div class="center">Регистрация</div>
        <input v-model="name" placeholder="Введите имя">
        <input v-model="login" placeholder="Введите логин">
        <input v-model="password" type="password" placeholder="Введите пароль">
        <input v-model="confirmPassword" type="password" placeholder="Подтвердите пароль">
        <div v-show="errorMessage.length > 0" class="center" style="margin-bottom: 10px;">
            {{ errorMessage }}
        </div>
        <div class="center">
            <button :disabled="isLoading" @click="register">
                Зарегестрироваться
            </button>
        </div>
    </Form>
</template>

<style scoped>
</style>