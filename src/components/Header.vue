<script setup>
import { useRouter } from 'vue-router'
import { jwtDecode } from 'jwt-decode'

const user = localStorage.getItem('authToken')

const router = useRouter()

function login() {
    router.push({name: 'Login'})
}

function register() {
    router.push({name: 'Register'})
}

function profile() {
    const role = jwtDecode(user).role
    switch (role) {
        case "PILOT": router.push({name: "Profile"}); break;
        case "ACCOUNTANT": router.push({name: "AccountantProfile"}); break;
        case "ADMINISTRATOR": router.push({name: "AdminProfile"}); break;
    }
}

function exit() {
    localStorage.removeItem('authToken')
    alert("Вы вышли из системы")
    location.reload()
}
</script>

<template>
    <header class="header">
        <router-link to="/planes">
            <img src="/nano_banana-logo.png" class="logo">
        </router-link>

        <p class="header-name">Sky <br> Racer</p>

        <ul class="header__buttons">
            <li v-if="user == null">
                <button class="header__button" @click="login">Войти</button>
            </li>
            <li v-if="user == null">
                <button class="header__button" @click="register">Зарегистрироваться</button>
            </li>

            <li v-if="user != null">
                <button class="header__button" @click="profile">Профиль</button>
            </li>
            <li v-if="user != null">
                <button class="header__button" @click="exit">Выйти</button>
            </li>
        </ul>
    </header>
</template>

<style scoped>
.header {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    align-items: center;
}

.header-name {
    font-family: 'Montserrat', sans-serif;
    text-transform: uppercase;
    font-size: 38px;
    font-weight: 700;
    text-align: center;
    color: #fff;
    text-shadow: 1px 1px 2px rgba(0, 0, 0, 1);
}

.logo {
    width: 35%;
    height: 25%;
}

.header__buttons {
    display: flex;
    flex-direction: column;
    gap: 20px;
    justify-content: center;
    align-items: end;
    margin-right: 40px;
}

.header__button {
    width: 175px;
    height: 30px;
    text-transform: uppercase;
    cursor: pointer;
    border-radius: 6px;
    font-weight: 600;
    transition: all 0.2s ease;
    background-color: #1E3C72;
    color: #fff;
}

.header__button:hover {
    transform: scale(1.02);
}
</style>